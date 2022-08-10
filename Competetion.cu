#include<iostream>
#include<cstdlib>
#include<stdio.h>
//#include "Runner.h"




const int rN = 100;

using namespace std;

class Runner

{
    

  public:
    // Runner's Number
    int runnerNumber=0;
    //Runner's location in competetion.
    int location = 0;
    //Runner's momentary speed.
    int speed = 0;
    //Runeer's finishing place.
    int place;
    //Runner Constructor function and Runner's starting to race.
    Runner(int number);


//Function that provides to runners move. 
__host__ __device__ void run(Runner** test,int i)
{
   test[i]->location+= test[i]->speed;
} 


};
Runner::Runner(int number)
{
   runnerNumber = number;
}
////////////////////////////////////////////////////////////////
// this is the actual device routine that is run per thread
__global__ void myKernel(Runner** runner)
{
int idx = threadIdx.x+blockDim.x*blockIdx.x; // figure out which thread we are

for(int i = 0; i <= rN; i++)
{

runner[idx]->run(runner,idx);
//runner[idx]->location+= runner[idx]->speed;
printf("Runner %d, speed %d",runner[idx]->runnerNumber,runner[idx]->speed);
}

}


int main()
{
// allocate host data
//Runner **runner;
//runner = new Runner*[rN];
//Runner *cpyrunner;
Runner* runner[rN];

int chck=0;

// allocate device data
//cudaMalloc(cpyrunner,sizeof(Runner*));


// initialize host data
for(int i = 0 ;i < rN; i++)
{
   runner[i] = new Runner(i);
   // *(runner + i)= new Runner(i);
}

//Generate device array for storing host array.
Runner** cpyrunner = (Runner**)malloc(sizeof(Runner*)*rN);

for(int i=0; i<100;i++)
{
cudaMalloc((void**)&cpyrunner[i],sizeof(Runner));
cudaMemcpy(cpyrunner[i],&(runner[i]),sizeof(Runner),cudaMemcpyHostToDevice);
}

Runner** prunner = NULL;
cudaMalloc((void**)&prunner,sizeof(Runner*)*rN);
cudaMemcpy(prunner,cpyrunner,sizeof(Runner*)*rN,cudaMemcpyHostToDevice);



///////////////

while(chck <= 99)
{
int winner = 1 ;

for(int i = 0; i < 100;i++)
{   
runner[i]->speed = rand()%5 +1;
cudaMemcpy(cpyrunner[i],&(runner[i]),sizeof(Runner),cudaMemcpyHostToDevice);
}
cudaMemcpy(prunner,cpyrunner,sizeof(Runner*)*rN,cudaMemcpyHostToDevice);

//To transfer from host to device
myKernel << < 99,0 >> > (prunner);
cudaDeviceSynchronize();

//To print competetion state
for(int i=0 ; i<100; i++)
{
   int line = runner[i]->location;


   if(line == 100)
   {
   chck++;
   runner[i]->place = i + 1;
   }
   else{}

   if(chck==1)
   {
       cout << "Location : " << runner[i]->location << "speed : " << runner[i]->speed << "m/s";
   }

}

for(int i=0; i < 100;i++)
{
cout<< "Race Number: "<< runner[i]->runnerNumber << "Fınıshed Competetion  as = #"<<runner[i]->place;

}

}





return 0;
}