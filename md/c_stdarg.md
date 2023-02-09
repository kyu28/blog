# C/C++变长参数列表入门
*没错，就是scanf、printf同款那个*

---

## 1.头文件
C  
`#include <stdarg.h>`  
C++  
`#include <cstdarg>`  

---

## 2.基础用法
```
//用到变长参数列表的函数至少要有一个参数
//在最后一个确定参数后原本写参数名的位置写省略号`...`

va_list vl;  //初始化一个变长参数列表handler（似乎本质就是个指针）
             //va for variable argument

void va_start(va_list ap, paramN);
      //paramN填入参数名
      //初始化一个变长参数列表，ap将指向paramN后第一个地址

type va_arg(va_list ap, type);
      //type填入数据类型
      //这是个宏函数，类型根据所填内容宏展开而更改
      //将ap地址后type类型大小的内容以type类型返回

void va_end(va_list ap);
      //结束使用va_list后，通过该函数销毁列表以便函数正常返回
```

---

## 3.实例
```
#include <stdio.h>
#include <stdarg.h>

void func(int para1, ...){  //变长部分写...
  va_list vl;              //声明列表handler

  int tmp;

  va_start(vl,para1);      //用第一个参数和列表handler初始化一个列表

  printf("%d\n",para1);

         //因列表无法直接判断是否到达结尾，故以0作为中断条件
  while((tmp=va_arg(vl,int))) //获取下一个参数
    printf("%d\n",tmp);

  va_end(vl);              //销毁列表
}

int main(){
  func(1,2,3,4,5,6,7,8,9,0);
}
```
输出  
```
1
2
3
4
5
6
7
8
9
```
