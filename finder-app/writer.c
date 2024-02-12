#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <syslog.h>

int main(int argc, char *argv[]) {
    openlog(NULL, 0, LOG_USER);
    // Check if 2 arguments were provided
    if (argc != 3) {
        syslog(LOG_ERR,"Usage: %s <writefile> <writestr>\n",argv[0]);
        exit(1);
    }
    // Create the file with writefile as filename and writestr as content
    char *writefile = argv[1];
    char *writestr = argv[2];
    FILE *fptr = fopen(writefile, "w");
    if (fptr == NULL) {
        syslog(LOG_ERR,"Failed to create file %s\n",writefile);
        exit(1);
    }
    fprintf(fptr, "%s", writestr);
    fclose(fptr);
    // Verify if the file was successfully created
    struct stat st;
    if (stat(writefile, &st) != 0) {
        syslog(LOG_ERR,"Failed to create file %s\n",writefile);
        exit(1);
    }
    syslog(LOG_DEBUG,"File %s Created",writefile);
    return 0;
}