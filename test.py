import sys
from antlr4 import *
import antlr4
from NewShLexer import NewShLexer
from NewShParser import NewShParser


class MyCustomListener(ParseTreeListener):
    
    def __init__(self) -> None:
        self.statements = []
        self.for_stack = [] # stack to store indices of for in list
        self.while_stack = []
        self.if_stack = []
        self.ignorable_parents = set(['custom_for_clause','for_assign', 
                                      'custom_while_clause', 'arith_expr', 'filename', 'assign', 'custom_if_clause']) # do not unparse if a parent somewhere up the AST 
        # modified child nodes
        self.custom_children = ['assign', 'for_assign', 'custom_while_clause',
                                'custom_for_clause', 'custom_if_clause', 'array_length', 'array_items', 'arith_expr', 'expr', 'expr2', 'filename'
                                , 'brace_group_mod', 'for_array_items']

        super().__init__()


    # generic entry function
    def generic_entry(self, ctx):
        result = None
        ctx.result = result # this is obtained from a parser action

    def generic_exit(self, ctx):
        # get the parent 
        parent_ctx = ctx.parentCtx
        context_type = None # predefine context_type for loop
        parentList = []
        
        # bubble up the tree
        # prevent double unparsing
        while parent_ctx != None:
            context_type = parent_ctx.getRuleIndex() # this is a number
            parentList.append(NewShParser.ruleNames[context_type]) # get the actual rule name
            
            if len(set(parentList).intersection(self.ignorable_parents)) > 0:
                return super().exitEveryRule(ctx) # default return
            parent_ctx = parent_ctx.parentCtx
        
        # print(ctx.result)
        self.statements.append(ctx.result)  

    def enterExpr(self, ctx):
        self.generic_entry(ctx)

    def enterExpr2(self, ctx):
        self.generic_entry(ctx)

    def enterFilename(self, ctx):
        # print("entering filename: ", self.statements)
        self.generic_entry(ctx)

    def exitFilename(self, ctx):
        
        self.generic_exit(ctx)
        # print("exiting filename: ", self.statements)

    def exitExpr(self, ctx):
        self.generic_exit(ctx)
    
    def exitExpr2(self, ctx):
        self.generic_exit(ctx)

    def enterArith_expr(self, ctx):
        self.generic_entry(ctx)
    
    def exitArith_expr(self, ctx):
        self.statements.append(ctx.result)

    def enterArray_length(self, ctx):
        self.generic_entry(ctx)

    def enterArray_items(self, ctx):
        self.generic_entry(ctx)

    def enterArray_defn(self, ctx):
        self.generic_entry(ctx)

    def exitArray_length(self, ctx):
        self.statements.append(ctx.result)

    def exitArray_items(self, ctx):
        self.statements.append(ctx.result)
        
    def enterFor_array_items(self, ctx):
        self.generic_entry(ctx)

    def exitFor_array_items(self, ctx):
        self.generic_exit(ctx)

    

    def exitArray_defn(self, ctx):
        self.statements.append(ctx.result)


    def enterBrace_group_mod(self, ctx):
        self.generic_entry(ctx)

    def exitBrace_group_mod(self, ctx):
        self.generic_exit(ctx)    

    def enterWordlist(self, ctx):
        result = None  # Initialize with a default value if needed
        ctx.result = result



    def exitWordlist(self, ctx):
        # print(ctx.result)
        pass

    def enterAssign(self, ctx):
        result = None  # Initialize with a default value if needed
        ctx.result = result

    def exitAssign(self, ctx):
        self.statements.append(ctx.result)

    def enterFor_assign(self, ctx):
        result = None  # Initialize with a default value if needed
        ctx.result = result

    

    def exitFor_assign(self, ctx):
        self.generic_exit(ctx)
    
    def enterCustom_for_clause(self, ctx):
        result = None
        self.for_stack.append(len(self.statements))
        # print(self.for_stack)
        ctx.result = result

    def exitCustom_for_clause(self, ctx):
        print(self.for_stack)
        val = self.for_stack.pop()
        self.statements = self.statements[:val] + [ctx.result,] + self.statements[val:]
    
    def enterCustom_while_clause(self, ctx):
        result = None
        self.while_stack.append(len(self.statements))
        
        ctx.result = result

    def exitCustom_if_clause(self, ctx):
        
        val = self.if_stack.pop()    
        # while only accepts do and done
        self.statements = self.statements[:val] + [ctx.result,"\nthen\n"] +  self.statements[val:] + ["\nfi\n",]

    def enterCustom_if_clause(self, ctx):
        result = None
        self.if_stack.append(len(self.statements))
        
        ctx.result = result

    def exitCustom_while_clause(self, ctx):
        
        val = self.while_stack.pop()    
        # while only accepts do and done
        self.statements = self.statements[:val] + [ctx.result,"\ndo\n"] +  self.statements[val:] + ["\ndone;\n",]

    def visitTerminal(self, ctx):
        parentList = []
        
        parent_ctx = ctx.parentCtx
        original_parent = ctx.parentCtx
        while parent_ctx != None:
            context_type = parent_ctx.getRuleIndex()
            parentList.append(NewShParser.ruleNames[context_type])
            if len(set({"for_comparison", "for_loop_expr", "array_defn"}).intersection(set(parentList))) != 0:
                return super().exitEveryRule(ctx)
            parent_ctx = parent_ctx.parentCtx



        context_type = original_parent.getRuleIndex()
        if NewShParser.ruleNames[context_type] not in self.custom_children:
            self.statements.append(ctx.getText())

        return super().exitEveryRule(ctx)

def unparse(root : ParserRuleContext, parser) -> str:
    my_list = []
    
    

    if "result" in dir(root):
        print("assign!")
    if root.getChildCount() == 0:
        data = root.getText()
        print("data", data)

        if "result" in dir(root):
            data = root.result
            print("data", data)
            


        my_list += [data]
        return my_list
    
    if "children" in dir(root) and root.children is not None:
            for node in root.children:
                my_list += unparse(node, parser)
    return my_list

# main file from:
# https://jason.whitehorn.us/blog/2021/02/08/getting-started-with-antlr-for-python/

def main(argv):
    if len(sys.argv) > 1:
        infile = FileStream(sys.argv[1])
    else:
        infile = InputStream("\n".join(sys.stdin.readlines()))



    if len(sys.argv) > 2:
        outfile = sys.argv[2]

   
    lexer = NewShLexer(infile)
    
    tokens = CommonTokenStream(lexer)
    parser = NewShParser(tokens)
   

    listener = MyCustomListener()
    parser.addParseListener(listener)

    tree = parser.program()


    # print(tree.toStringTree(recog=parser))

    # for token in tokens.getTokens(0, 100):
    #     print(token)
    # print(listener.statements)
    # print("Unparsed tree: ", " ".join(listener.statements))

    with open(outfile, "w") as ofile:
        ofile.write(" ".join(listener.statements))
    

if __name__ == '__main__':
    main(sys.argv)
