#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h> 
#include <unistd.h> 
#include <sys/wait.h>
#include <signal.h>
#include <stdbool.h>

#define WITH_SIGNALS

#ifdef WITH_SIGNALS
//global variable for my sigint handler
bool mark = false;
//marker indicating that child processes were created
bool created = false;
//arrach with child pids
int childPids[5];
#endif
//how many children to create
int howMany = 5;

#ifdef WITH_SIGNALS
//own signal handlers
void sigIntHandler(int sig_num){
    printf("parent[%d]: received interrupt, sending SIGTERM to child processes\n", getpid()); 
    mark = true;
    //send sigterm also after creating children
    if(created == true){
        for(int i=0;i<howMany;i++)
            {
                kill(childPids[i], SIGTERM);
            }    
    }
}

void sigTermHandlerChild(int sig_num){
    printf("child[%d]: SIGTERM received, terminating execution\n", getpid()); 
}
#endif


//parent process
void childProcesses(int howMany){
    pid_t forkResult;
    
    #ifdef WITH_SIGNALS
    //ignore all signals
    signal(SIGINT, SIG_IGN);
    //except for SIGCHLD
    signal(SIGCHLD, SIG_DFL);
    //own SIGINT handler
    signal(SIGINT, sigIntHandler); 
    #endif
    
    // create NUM_CHILD children
    for(int i=0;i<howMany;i++)
    {   
        #ifdef WITH_SIGNALS
        //between the two consequtive creations of new processes
        //if ctrl+c was pressed, send sigterm to all children
        if(mark == true){
            for(int i=0;i<howMany;i++)
            {
                kill(childPids[i], SIGTERM);
            }    
        }
        #endif
        
        forkResult = fork();
        // child process
        if(forkResult == 0) 
        { 
            #ifdef WITH_SIGNALS
            //fill the array of child pid's
            childPids[i] = getpid();
            //ignore all signals
            signal(SIGINT, SIG_IGN);
            //own SIGTERM handler
            signal(SIGTERM, sigTermHandlerChild); 
            #endif
            
            printf("child[%d]: identifier of the parent process: %d\n", getpid(), getppid()); 
            //sleep 10 seconds (execution)
            sleep(10);
            printf("child[%d]: execution complete\n", getpid()); 
            exit(0); 
        }
        //error when creating a child
        else if(forkResult < 0){
            fprintf(stderr, "child[%d]: error\n", getpid()); 
        }
        //sleep 1 second between creating children
        sleep(1);
    }
    
    #ifdef WITH_SIGNALS
    created = true;
    if(mark != true)
    #endif
    printf("parent[%d]: child processes created successfully\n", getpid());
    for(int i=0;i<howMany;i++){
        // wait for child processes to end
        wait(NULL); 
    }
    printf("parent[%d]: no more child processes\n", getpid());
    
    //restore old handlers
    #ifdef WITH_SIGNALS
    signal(SIGINT, SIG_DFL);
    #endif
}

int main() {
   
    childProcesses(howMany);

    return 0;
}

