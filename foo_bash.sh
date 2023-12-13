a=(1 2 3 4) 
 
 echo ${#a[@]} 
 
 echo ${a[@]} 
 
 for i in ${a[@]}
 { 
 echo $i 
 echo ${a[@]} 
 echo ${#a[@]} 
 }