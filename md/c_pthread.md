# C POSIX多线程编程入门  
*注意不是多进程*  
本文介绍的是POSIX线程标准下的多线程  

---

## 1.头文件
`#include <pthread.h>`  
编译时需加上`-lpthread`  
例:`gcc main.c -lpthread`  

---

## 2.常用操作
```
pthread_t t1; //创建一个pthread类型的handler  

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void*), void *arg);  
       //创建新进程  
       //第一个参数为pthread的handler,第二个参数为初始化参数  
       //第三个参数是这个线程要执行的函数，第四个参数传递将执行函数的参数  
       //函数返回值为0则创建成功，否则失败  

int pthread_join(pthread_t th, void **thr_return);  
       //挂起执行这个函数的线程来等待th线程  
       //th线程的返回值会被放到thr_return中  

void pthread_exit(void *arg);  
       //结束当前线程并返回arg所指值  

int pthread_detach(pthread_t th);  
       //把th线程从当前进程分离，线程退出后操作系统将自动回收它的资源  

int pthread_cancel(pthread_t th);  
       //杀死th线程  

PTHREAD_MUTEX_INITIALIZER  
       //一个pthread互斥锁初始化对象的宏定义  
       //用法：pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;  

int pthread_mutex_lock(pthread_mutex_t *mutex);    
       //锁定互斥锁，防止多个线程竞争资源导致非法情况   
       //第一个拿到锁的线程会继续执行  
       //后面拿到锁的会被阻塞，排队等候锁释放，逐个执行  

int pthread_mutex_unlock(pthread_mutex_t *mutex);  
       //释放互斥锁  
```

---

## 3.实例

```
#include <stdio.h>
#include <pthread.h>
#define THREADS 4          //线程数

int pubNum=2;              //本例中的公共资源
pthread_mutex_t mutex=PTHREAD_MUTEX_INITIALIZER; //初始化互斥锁

//多线程将执行的函数
void * func(void * arg){
  printf("Thread %d print\n",*(int*)arg);

  pthread_mutex_lock(&mutex);  //锁定互斥锁，其他未拿到锁线程执行到此句将被阻塞

  if(pubNum>0){                //模拟库存减少操作，pubNum不能小于0
    printf("Thread %d, Public Num -1\n",*(int*)arg);
       //做一些无意义的事，让判断和自减存在时间差，方便后续对比
    for(int i=0;i<100;i++){}
    pubNum--;
  }else{
    printf("Thread %d, Public Num is 0\n",*(int*)arg);
  }

  pthread_mutex_unlock(&mutex);    //公共资源操作完成，解锁互斥锁

  return NULL;
}

int main(){
  pthread_t t[THREADS];                         //创建线程handler
  int err,para[THREADS];

  for(int i=1;i<=THREADS;i++){
    para[i-1]=i;         //参数
    err=pthread_create(&t[i-1],NULL,func,&para[i-1]); //创建线程
    if(err!=0)           //判断是否创建成功
      return 1;
  }

  void *p=NULL;
  for(int i=1;i<=THREADS;i++){
    pthread_join(t[i-1],&p);  //等待线程合并
    printf("Thread %d join\n",i);
  }

  printf("Public Number:%d\n",pubNum); //检验pubNum
}
```
输出，可见各线程并非按顺序执行  
```
Thread 1 print
Thread 1, Public Num -1
Thread 2 print
Thread 4 print
Thread 2, Public Num -1
Thread 1 join
Thread 3 print
Thread 4, Public Num is 0
Thread 2 join
Thread 3, Public Num is 0
Thread 3 join
Thread 4 join
Public Number:0
```
若注释掉互斥锁，则输出有概率会  
```
Thread 2 print
Thread 2, Public Num -1
Thread 1 print
Thread 4 print
Thread 4, Public Num -1
Thread 1, Public Num -1
Thread 3 print
Thread 3, Public Num is 0
Thread 1 join
Thread 2 join
Thread 3 join
Thread 4 join
Public Number:-1
```
有线程在其他线程无意义操作阶段也进入了自减分支，导致判断失效，出现非法情况  
