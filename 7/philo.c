#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

//constants

#define N			5
#define LEFT		(id + N - 1) % N
#define RIGHT		(id + 1) % N

//numerical values for different states
#define THINKING 	1 
#define HUNGRY 		2
#define EATING		3 

//max number of meals for each philopher
#define FOOD_LIMIT	4

//sleep time
#define DELAY		2

//global variables

//internal mutex
pthread_mutex_t m;
//array of mutexes
pthread_mutex_t s[N];
//philosophers array
pthread_t p[N];
int	state[N];

//functions

//create a philosopher
void *create_philosopher(int id);
//forks functions
void grab_forks(int id);
void put_away_forks(int id);
//check state of current philosopher and neighbours
void checkState(int i);


int main()
{
    //initialization of mutex m
	pthread_mutex_init(&m, NULL);	
    //unlock it first
	pthread_mutex_unlock(&m);	
    
	for (int i=0; i<N; i++) 
	{ 
        //all th philosophers in the array are set to THINKING state
		p[i] = THINKING;	
        //initialise and lock all mutexes
		pthread_mutex_init(&s[i], NULL);	
		pthread_mutex_lock(&s[i]);
	}
	
	for (int i=0; i<N; i++)
        //create all philosophers with their threads
		pthread_create(&p[i], NULL, (void *)create_philosopher, (void *)i);	
	
	for (int i=0; i<N; i++)
        //after the end of philophers actions, the thread is destroyed
		pthread_join(p[i], NULL);	

	for (int i=0; i<N; i++)
        //destroy mutextes too
		pthread_mutex_destroy(&s[i]);	
}

//functions

//create a philosopher and his actions
void *create_philosopher(int id)
{
	printf("Philosopher [%d] arrives to the table\n", id);
    //number of meals 
	for(int i=0; i<FOOD_LIMIT; i++)	
	{
		printf("Philosopher [%d] is thinking\n",id);
        //thinking time
		sleep(DELAY);	
        //philo grabs fork
		grab_forks(id);
		printf("Philosopher [%d] is eating his meal\n",id);
        // eating time
		sleep(DELAY);
        //put away fork after eating
		put_away_forks(id);
		printf("Philosopher [%d] finishes his meal\n",id);
	}
	//end of philo's actions
	printf("Philosopher [%d] leaves the table\n", id);
}

//forks functions
void grab_forks(int id)
{
    //locking the internal mutex, because only one process should be going at once
	pthread_mutex_lock(&m);	
    //changing the state of philo
    state[id] = HUNGRY;	
    //check if he can eat
    checkState(id);	
    //unlocking the internal mutex
	pthread_mutex_unlock(&m);	
    //locking the philo
	pthread_mutex_lock(&s[id]);	
}

void put_away_forks(int id)
{
    //same as grab_forks
	pthread_mutex_lock(&m);	
    //changing the state of philo
    state[id] = THINKING;	
    //testing both left and right neighbours
    checkState(LEFT);	
    checkState(RIGHT);
    //unlocking the internal mutex
	pthread_mutex_unlock(&m);	
}

//check state of current philo and neighbours
void checkState(int id)
{
    //if philo is hungry and left & right neighbours are not eating
    //then philo has 2 forks available and can eat
	if(	state[id] == HUNGRY && state[LEFT] != EATING && state[RIGHT] != EATING) 
	{
        //philo starts eating
		state[id] = EATING;	
		pthread_mutex_unlock(&s[id]);
	}
}
