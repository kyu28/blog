# 将Shell用作编程语言指北
*POSIX Shell编程快速入门指南*  
*不保证教完，但学完能用*

---

## 前言

开始学习前请先准备好Shell编程环境  
确保有sh、bash、ash（busybox里那个也行）、zsh、fish、ksh、csh等**其中一个Shell解释器即可，PowerShell除外**  
*除非是Windows不然一般都有Shell解释器，无视这一步就行*  
*什么，你是Windows用户？自行学习如何安装WSL或MSYS2或用busybox-w32或git for windows里的git bash*  
  
在解释器后你需要一个趁手的文本编辑器，Vi、Vim、nano、Emacs、VSCode甚至是记事本都是可以的  
新建一个`xxx.sh`文件，开始你的代码编写  

+ 1.为什么用Shell？
    - 1.1 不管是Linux还是Unix，有*nix的地方，就有Shell；Windows可以装Shell
    - 1.2 极其容易满足的依赖，只要有Shell解释器就能跑
    - 1.3 不需编译，节约时间
+ 2.为什么是POSIX Shell？
    - 2.1 POSIX Shell是规定的通用标准，不管是哪个Shell解释器都兼容POSIX语法，保证了可移植性
    - 2.2 上述加成可以保证在安卓设备、嵌入式设备和运行Linux的路由器上都能保证代码可以运行
+ 3.为什么用Shell做这么复杂的事，用Python不好吗？
    - 3.1 Python好，但是Python还有细分版本，Python 2和Python 3以及具体小版本还有语法差异，不能保证通用
    - 3.2 Shell相比Python资源开销更小
    - 3.3 不觉得这很酷吗

---

## 第一个Shell程序
*传统艺能*  
```
#!/bin/sh
echo "Hello world!"
```
将以上内容写入`hello_world.sh`，`chmod +x hello_world.sh`后`./hello_world.sh`  
或直接`sh hello_world.sh`  
应当能看到如下输出  
`Hello world!`  
除了以下章节所讲内容，一般一个语句的第一个词会被解释器认为为要调用的程序   
如`sh hello_world.sh`中`sh`就是要被调用的名叫`sh`的程序  
这个程序会在环境变量的PATH变量中记录的路径中逐一查找  

---

## 注释
`#`后本行的剩余内容将被解释器忽略，不被执行  
  
**PS：关于Shebang**  
你可能会在一些脚本文件里的第一行看到如下字眼  
`#!/bin/sh`  
这行用于指定运行该文件所用的程序，`#!`被称之为Shebang  
上述该行代码指示以它开头的这个文件用`/bin/sh`这个程序运行  
  
*什么？*`/bin/sh`*是什么程序，和*`sh`*有什么区别？快去学相对路径和绝对路径*  
*真没办法，*`/bin/sh`*就是指在系统根目录下*`bin`*目录下的*`sh`*程序啦*  

---

## 变量
对于Shell而言，所有值都是字符串  
值可以用双引号`"`或单引号`'`包裹起来，效果不变  

+ 变量赋值  
```
var_name=123 # 等号左右不能有空格
var_name="123" # 和上面没区别
abc=a # 变量abc的值为a这个字符串
```

+ 使用变量的值  
在变量名前加`$`表示取变量的值
变量名前后还可以加上`{}`以帮助解释器区分变量名的边界
```
var_name=123
another_var=$var_name # another_var的值为123
third_var=$another_var4
# third_var的值为空，因为解释器认为在取another_var4这个变量的值，未被设定的变量默认取值时为空
third_var=${another_var}4 # third_var的值为1234，没错，这就是字符串拼接
```
*取值时关于引号注意事项*  
`"`和`'`包裹值时的含义不同，单引号包裹时值中的变量及特殊字符不会被替换，双引号包裹时会  
```
var_name=123
another_var='$var_name' # another_var的值是$var_name这个字符串的字面值
another_var="$var_name" # another_var的值是123
```

+ 特殊字符及转义  
在赋值过程中，没有引号或双引号中的特殊字符及变量会被替换为其代表的值或变量的值  
    - `*`在上述情况中表示当前工作文件夹下的所有文件（不含隐藏文件，即`.`开头的文件）
    - `$`会被解释成取变量值的符号故也不能直接存在于字母及数字前
    - 引号不能嵌套所以被双引号包裹的双引号不能直接存在  
    - ...

那么上述情况要如何解决？这就要引入转义符号--反斜杠`\`  
在需要转义为字面值的符号前加上`\`表示不要替换该字符原本表达的其他值  
`\`本身也能以相同的办法转义  
```
var_name="*" # var_name的值是该文件夹下所有非隐藏文件的文件名以空格为分格拼接成的字符串
var_name="\*" # var_name的值是*
var_name="\"" # 在双引号中塞双引号
var_name="\\" # var_name的值是\
```

+ 位置参数  
调用函数或别的脚本的时候，有时后面会带上参数，就像这样  
`xxx@xxx $ my_script.sh param1 param2`  
这里的参数会以位置参数的形式传给脚本  
以上述脚本调用为例，`$0`的值为脚本名本身`my_script.sh`  
`$1`的值为`param1`，`$2`的值为`param2`  
脚本中可以通过`var_name=$1`将`param1`这个字符串赋值给`var_name`  
大于9的位置参数可以在数字前后加上`{}`来调用，如`${11}`  
特别的，`$@`和`$*`表示所有的位置参数，前者是独立的每个参数，后者则将所有位置参数拼接成一个字符串  
`$#`表示位置参数的个数  

---

## 输入输出
+ 输出字符串或值到标准输出（stdout）  
`echo`输出所有参数字符串，输出后换行，类似C的`puts`和Python的`print`  
`printf`模拟C的`printf`函数的产物，用法基本一致，第一个参数作为模式串，后面参数用于替换模式串中的格式化符号  
```
var_name="Hello world"
echo $var_name # 和第一个Shell程序等效
printf "%s\n" $var_name # 和echo版等效
```
  
+ 从标准输入读取用户输入（stdin）  
`read`用于读取用户输入，需将读入信息存放至的变量作为参数传入  
```
read var_name # 程序会阻塞等待用户输入，以回车结束
echo $var_name # 输出用户上一句中输入的信息
```

+ 输入输出重定向  
输入输出也可以不从标准输入、标准输出中进行，而是从特定的文件，即重定向输入输出  
    - `>`、`>>`两个符号用于重定向输出  
      `>`用于从文件开头写入脚本输出的内容（即抹除文件原有的信息）  
      `>>`用于将脚本输出的内容接续至文件末尾（不抹除原文件内容）  
    - `<`用于将文件内容作为标准输入输入给脚本读取，替换用户输入  
    - `|`管道符，用于将前一个程序的输出作为下一个程序的输入  
```
echo "Hello world" > hello.txt # hello.txt若不存在则被新建，存在则被清空，并写入"Hello world"
echo "Hello Shell" >> hello.txt # 同上，但不清空已存在文件，故hello.txt现在有两行
echo "No more hello" > hello.txt # hello.txt被清空并写入"No more hello"
read var_name < hello.txt # var_name的值是hello.txt的内容，即"No more hello"
cat hello.txt | less # cat程序将输出hello.txt的内容，并将其作为less程序的输入
```

---

## 运算符

+ 预备知识：运算发生的环境  
数学运算一般发生在`$(())`的里层括号中且这种运算**仅支持整型**  
布尔运算一般发生在`[]`中，对于Shell这一般用以判断某个语句的真或假  
  
+ 数学运算  
**仅当在双括号`(())`中的表达式才会被认为是数学运算**  
常用运算符 `+ - * / % ?: ( )` 同C用法  
```
a=1+2 # a的值是"1+2"
a=$((1+2)) # a的值是3
sp=$(((11+451)*4+((1+14)*5-1*4))) # sp的值是1919
sp=$(($sp*1000 + 810)) # sp的值是1919810
```
+ 布尔运算  
发生在中括号`[]`当中  
与C等其他语言不同的是：**0代表真，非0代表假**  
*程序无异常时return 0，异常时return非0值*  
    - 数学比较  
    `-eq` equal to的缩写，等于  
    `-ne` not equal to的缩写，不等于  
    `-gt` greater than的缩写，大于  
    `-lt` less than的缩写，小于  
    `-ge` greater than or equal to的缩写，大于等于  
    `-le` less than or equal to的缩写，小于等于  
      
    - 字符串比较  
    `=` 字符串字面值相等  
    `!=` 字符串字面值不相等  
    `-n` 一元运算符，字符串长度不为0  
    `-z` 一元运算符，字符串长度为0  

    - 文件属性相关  
    均为一元运算符，用法同字符串的一元运算符  
    `-e` 存在该文件或文件夹（符号链接则查验其链接到的文件）  
    `-d` 存在该文件夹（符号链接则查验其链接到的文件）  
    `-h` 存在该符号链接（查验符号链接本身，而不是其链接到的文件）  
    
    - 逻辑运算符  
    `!` 非  
    `&&` 短路与  
    `||` 短路或  
```
[ 1 -eq 1 ] # 结果为真，中括号和表达式间的空格不得省略
[ $((1+2)) -gt 2 ] # 结果为真
[ "abc" != "abc" ] # 结果为假
[ ! -z "abc" ] # 字符串长度不为0，但取反，结果为真
echo 1 > a.txt # 假设该行成功创建a.txt文件
[ -e "a.txt" ] && [ 2 -eq 2 ] # 存在该文件且2等于2，结果为真
[ 2 -le 1 ] && a=3 # 结果为假且a没有被赋值
```

---

## 选择结构
Shell有多种选择结构，包含if、case（类似switch）  
+ if  
同其他语言中的if  
```
if <判断语句>
then
  <语句>
elif <判断语句> # 可选
then
  <语句>
else #　可选
  <语句>
fi # 就是if倒着写，即其它语言中的反大括号
```
`then`可以利用`;`写到和`if`或`elif`同一行  
```
a=1
if [ $a -eq 1 ]; then
  a=$(($a+1))
elif [ $a -gt 1 ]; then
  a=0
else
  a=1
fi
if [ -n "$1" ]; then
  exit 0 # 以0为返回值退出整个程序
fi
# 奇技淫巧
[ -n "$1" ] && exit 0 # 与上方if等效
```
  
+ case
类似其他语言的switch
```
case <字符串> in
  <字符串>)
    <语句>
    ;; # 即break，但不可或缺
  <字符串>) # 使用*以实现default的效果
    <语句>
    ;;
esac # case倒着写，功能同if
```
示例  
```
a=1
case $a in
  1) a=2;;
  2) # 注意此例中该分支没有被执行
    echo "a was $a"
    a=$(($a+1))
    ;;
  *) echo "a is not 1 or 2";; # 任何非1非2的情况
esac
```

---

## 循环结构
Shell有多种循环结构，包含for、while、until  
为保证简练本文仅介绍for和while循环
+ 循环控制  
`break`和`continue`同其它语言，此处不再赘述  

+ for  
类似Python的for ... in ...，POSIX Shell中并没有C风格循环
```
for <变量名，不含$> in <值集合>
do
  <语句>
done
```
`do`可通过`;`放至和`for`一行，`while`同  
```
sum=0
for i in 1 2 3 4 5; do
  sum=$(($sum+$i))
done
val_set="a b c d e f g"
for i in $val_set; do
  echo "$i"
done
# 奇技淫巧，下面的代码将输出该文件夹下所有非隐藏文件
for i in *; do
  echo "$i"
done
```

+ while  
同其他语言的while  
```
while <判断语句>
do
  <语句>
done
```
示例  
```
a=0
while [ $a -lt 100 ]; do
  echo "a=$a"
  a=$(($a+1))
done
b=0
while true; do
  [ $b -gt 10 ] && break
  if [ $b -lt 5 ]; then
    b=$(($b+2))
    continue
  fi
  b=$(($b+1))
done
```

---

## 函数
概念与其他语言类似，Shell函数返回值仅能是整数  
在不return时函数返回值为最后一条语句的返回值  
通过`$?`取上一条语句的返回值
```
<函数名>() {
  <语句>
}
```
示例
```
func() { # 声明一个函数
  a=$1 # 第一个参数赋值给a
  b=$2 # 第二个参数赋值给b
  sum=$(($a+$b))
  echo $sum
  return $sum # 返回sum的值
}

func 1 2 #　调用func且参数为1和2
echo $? #　将输出3
```

---

## 文本替换
本节将介绍命令替换和字符串替换
+ 命令替换  
命令替换是将某个命令的输出拼接到另一句命令中  
命令替换的中被需要输出的命令将要放在`$()`中  
*亦可放在反引号对\`\`中，但这是一种古老而不被推荐的做法，难以嵌套使用*  
```
echo 3 > test.txt # 将3写入test.txt中
num=$(cat test.txt) # cat程序输出test.txt的值，即3，并将输出的结果3赋值给num
[ $(cat test.txt) -eq 3 ] && exit #　test.txt中的数值结果为3则退出
```
  
+ 字符串替换
即字符串的一些操作，用于裁剪字符串或获取字符串的一些信息  
下列模式串中，未被单引号包裹的`*`表示任意长度的任意字符串，未被单引号包裹的`?`表示任意单个字符  
特殊符号依然可用反斜杠转义  
`${<变量名>#<模式串>}`从头去除最短模式串匹配的文本的剩余字符串  
`${<变量名>##<模式串>}`从头去除最长模式串匹配的文本的剩余字符串  
`${<变量名>%<模式串>}`从尾去除最短模式串匹配的文本的剩余字符串  
`${<变量名>%%<模式串>}`从尾去除最长模式串匹配的文本的剩余字符串
`${#<变量名>}`获取字符串长度  
还有可以根据变量是否赋值的情况来替换为特定的值的字符串替换，但因为可以用`if`实现，本文不介绍该部分内容  
```
a=114514
echo ${a#*14} # 514，去除了'1'+'14'
echo ${a##*14} # 空输出，去除了'1145'+'14'
echo ${a%'14'} #　单引号被认为是包裹串的符号，1145
echo ${a%%?} # 11451
echo ${#a} # 6
echo ${a#'*'} # 单引号包裹，字符串中没有*这个符号，不作更改，114514
echo ${a%%45*}${a#*45} #　前缀和后缀拼接，去除中间的'45'，1114
```

---

## 引入其他“库”
可以像其他语言一样引入库一样引入其他shell脚本中的内容  
```
source xxx.sh
source /path/to/your/lib.sh
. xxx.sh
. /path/to/your/lib.sh
```

---

## 后台运行
`&` 用于将命令挂至后台运行（fork），不阻塞前台
```
ping 127.0.0.1 & echo "114514"　# ping将后台执行，不阻塞echo的执行
```

---

## 动态构建命令并执行
有时写死（hard-coded）的命令不能满足需求，此时我们可以动态构建命令  
使用`eval`，`eval`将所传参数作为命令执行 *和Python类似*  
```
for i in 3 4 5; do
  eval echo \$$i # 实现单独打印出位置为3、4、5的位置参数
done
```
**注意：`eval`有存在的注入攻击的风险，请不要在有用户输入的部分使用`eval`**  
```
read pos
eval echo \"Pos $pos = \${$pos}\" # 若用户输入 1}"; rm -rf /* #，会发生什么？
```

---

## 转义序列
*本文为快速入门，仅简单介绍转义序列*  
  
转义序列将特定的字符串和特定的操作绑定  
输出（printf）转义序列将会执行特定的操作，如**换行、移动光标、更改颜色、清屏**等  
POSIX Shell中一般兼容**ECMA-48**标准转义的转义序列，其中常用的是控制序列（CSI）  
如`ESC[2A`就是一个转义序列，其含义是将光标竖直上移两行  
其中`ESC`是转义符号，在printf中可用`\033`表示  
```
printf "\033[3A" # 光标上移三行  
```
利用转义序列可以开发出在CLI中的用户界面（GUI）程序  
*没错，就是ncurses和curses的原理*  

---

## 拓展阅读
[POSIX Shell命令语言标准](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)  
[ECMA-48原始标准，难以阅读](https://www.ecma-international.org/publications-and-standards/standards/ecma-48/)  