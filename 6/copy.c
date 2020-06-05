#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

//help message
const char * help = "Made by Alexander Wrzosek\n"
                    "The program copies one file to another " 
                    "using 2 different methods.\n"
                    "Syntax:\n"
                    "./copy [-m] <file_name> <new_file_name>\n"
                    "./copy [-h]\n"
                    "Without -m, the program uses read() and write().\n"
                    "With -m, the program uses mmap() and memcpy().\n"
                    "In both cases, 2 filenames have to be supplied.\n"
                    "First, source filename has to exists, second one can exist,\nits conted will be replaced by 1st file content.\n"
                    "If not, it will be created with content copied from first file.\n"
                    "./copy -h or without any argument will invoke help.\n"
                    ;

//function with same code for both versions
void copy(char * oldFile, char * newFile, bool withM);
//function for call without -m
//using read() and write()
void copyNoM(int fd, int fdNew, int bufSize);
//function to call with -m
void copyWithM(int fd, int fdNew, int bufSize);

int main(int argc, char *argv[])
{
    int option;
    char * oldFile;
    char * newFile;
    //to indicate which method will be used
    bool withM = false;
    
    //user didn't supply options or arguments
    //print help
    if(argc == 1){
        printf("%s", help);
        exit(0);
    }
    
    //get command line options
    while ((option = getopt (argc, argv, "mh")) != -1)
        switch (option)
        {
            case 'm':
                //only if user gave exactly 1 option with 2 args
                if(argc == 4){
                    //get 2 filenames
                    oldFile = argv[2];
                    newFile = argv[3];
                    withM = true;
                    copy(oldFile, newFile, withM);
                    exit(0);
                }
                else{
                    printf("copy -m requires exactly 2 arguments\n");
                    exit(1);
                }
            case 'h':
                //print help
                printf("%s", help);
                exit(0);
                break;
            case '?':
                printf("not supported option\n");
                exit(1);
                break;
        default:
            exit(1);
        }
    
    //copying without -m
    //only if user supplied exactly 2 filenames
    if(argc == 3){
        oldFile = argv[1];
        newFile = argv[2];
        copy(oldFile, newFile, withM);
    }
    else{
        printf("copy requires exactly 2 arguments\n");
        exit(1);
    }
    
    return 0;
    
}

//functions implementation

void copy(char * oldFile, char * newFile, bool withM){    
    
    int fd, fdNew, bufSize, check1, check2;
    
    //open for read and only if exists
    fd = open(oldFile, O_RDONLY | O_EXCL);
    
    //error happened
    if(fd == -1){
        printf("Error when opening file!\n");
        exit(1);
    }
    
     //open for write/read and create if doesn't exist
    fdNew = open(newFile, O_RDWR | O_CREAT, 0666);
    
    if(fdNew == -1){
        printf("Error when opening/creating file!\n");
        exit(1);
    }
    
    //size of buffer (from size of oldFile)
    bufSize = lseek(fd, 0, SEEK_END);
    if(bufSize == -1){
        printf("Error when processing file!\n");
        exit(1);
    }
    
    //change position to start again
    lseek(fd, 0, SEEK_SET);
    
    //choose appropriate method
    if(withM)
        copyWithM(fd, fdNew, bufSize);
    else
        copyNoM(fd, fdNew, bufSize);
    
    //close files
    check1 = close(fd);
    if(check1 == -1){
        printf("Error when closing file!\n");
        exit(1);
    }
    check2 = close(fdNew);
    if(check2 == -1){
        printf("Error when closing file!\n");
        exit(1);
    }
    
    printf("Copying succesfull!\n");
    
}

//copying without -m
void copyNoM(int fd, int fdNew, int bufSize){
    
    printf("Copying using read() and write():\n");
    
    int size, size2;
    //allocate memory space
    char * oldFileContents = (char *) calloc(bufSize, sizeof(char));
    
    //read contents of oldFile
    size = read(fd, oldFileContents, bufSize);
    
    if(size == -1){
        printf("Error when reading file!\n");
        exit(1);
    }
    
    //truncate if new file was bigger
    ftruncate(fdNew, bufSize);
    //write to new file
    size2 = write(fdNew, oldFileContents, bufSize);
    
    if(size2 == -1){
        printf("Error when copying file!\n");
        exit(1);
    }
}

//copy with -m
void copyWithM(int fd, int fdNew, int bufSize){    
    
    printf("Copying using mmap() and memcpy():\n");
    
    char * oldFileContents;
    char * newFileContents;
    
    //read contents of oldFile
    oldFileContents = mmap(NULL, bufSize, PROT_READ,
        MAP_PRIVATE, fd, 0);
    
    //truncate if new file was bigger
    ftruncate(fdNew, bufSize);
    //write to new file
    newFileContents = mmap(NULL, bufSize, PROT_READ | PROT_WRITE,
        MAP_SHARED, fdNew, 0);
    //copy
    memcpy(newFileContents, oldFileContents, bufSize);
    
    //unmap
    munmap(oldFileContents, bufSize);
    munmap(newFileContents, bufSize);
}
    
    
