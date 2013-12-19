#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <syslog.h>
#include <stdlib.h>

#define myfile "/usr/local/cpanel/3rdparty/siteapps/bin/siteapps_wrapper.pl"

// gcc src/plugin/siteapps/siteapps_wrapper.c -o bin/siteapps_wrapper
// chmod ugo+xs bin/siteapps_wrapper

void x_check_if_parent();

int main(int argc, char ** argv)
{

    x_check_if_parent();

    setuid(0);
    seteuid(0);
    execv(myfile, argv);
}

int does_file_exist(const char *path)
{
    struct stat file_stats;
    return stat(path, &file_stats) == 0;
}

void x_check_if_parent()
{
    char procpath[1024];
    char readlinkbuf[1024];
    int cpanelisparent = 0;
    pid_t ppid;

    if (does_file_exist("/var/cpanel/skipparentcheck"))
        return;

    ppid = getppid();

    snprintf(procpath, (sizeof(procpath) - 1), "/proc/%d", ppid);
    if (does_file_exist(procpath)) {
        snprintf(procpath, (sizeof(procpath) - 1), "/proc/%d/exe", ppid);
        if (does_file_exist(procpath)
            && readlink(procpath, readlinkbuf, sizeof(readlinkbuf) - 1) > 0) {
            if (readlinkbuf == strstr(readlinkbuf, "/usr/local/cpanel/cpanel")
                ) {
                cpanelisparent = 1;                                          
            } else {
                syslog(LOG_INFO, "cPWrapper run with a parent: %s\n", readlinkbuf);
            }
        }

        snprintf(procpath, (sizeof(procpath) - 1), "/proc/%d/file", ppid);
        if (!cpanelisparent && does_file_exist(procpath)
            && readlink(procpath, readlinkbuf, sizeof(readlinkbuf) - 1) > 0) {
            if (readlinkbuf == strstr(readlinkbuf, "/usr/local/cpanel/cpanel")
                ) {
                cpanelisparent = 1;
            } else {
                syslog(LOG_INFO, "cPWrapper run with a parent: %s\n", readlinkbuf);
            }
        }

        if (!cpanelisparent) {
            printf("This wrapper may only be run from the cpanel binary.  This setting can be adjusted in Tweak Settings.\n");
            syslog(LOG_INFO, "cPWrapper run with a parent other then cpanel\n");
            fflush(stdout);
            exit(1);
        }
    }
}
