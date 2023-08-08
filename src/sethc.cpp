#include <iostream>
#include <string>
#include <vector>
#include <windows.h>
#include <fstream>
#include <cstdlib>
#include <lm.h>
#pragma comment(lib, "netapi32.lib")
std::vector<std::wstring> getWindowsUsers() {
    std::vector<std::wstring> users;

    DWORD dwLevel = 0;
    LPUSER_INFO_0 pBuf = NULL;
    DWORD dwPrefMaxLen = MAX_PREFERRED_LENGTH;
    DWORD dwEntriesRead = 0;
    DWORD dwTotalEntries = 0;
    NET_API_STATUS nStatus;

    nStatus = NetUserEnum(NULL, dwLevel, FILTER_NORMAL_ACCOUNT, (LPBYTE*)&pBuf,
        dwPrefMaxLen, &dwEntriesRead, &dwTotalEntries, NULL);

    if (nStatus == NERR_Success) {
        for (DWORD i = 0; i < dwEntriesRead; i++) {
            users.push_back(pBuf[i].usri0_name);
        }
    }
    else {
        std::wcout << L"Error occurred while enumerating users: " << nStatus << std::endl;
    }

    if (pBuf != NULL) {
        NetApiBufferFree(pBuf);
    }

    return users;
}
std::string gettemp() {
    char tempPath[MAX_PATH];
    GetTempPathA(MAX_PATH, tempPath);

    std::srand(static_cast<unsigned int>(std::time(nullptr)));
    std::string tempFileName = "batch_script_" + std::to_string(std::rand()) + ".bat";
    return std::string(tempPath) + "\\" + tempFileName;
}

void uninstall() {
    const char* batchScript =
        "@echo off\n"
        "echo Trying to uninstall unshackle\n"
        "timeout 3\n"
        "setlocal\n\n"
        "if exist \"%SystemRoot%\\System32\\sethc.exe\" (\n"
        "    echo Removing sethc.exe...\n"
        "    del /f \"%SystemRoot%\\System32\\sethc.exe\"\n"
        "    echo sethc.exe successfully removed.\n\n"
        "    if exist \"%SystemRoot%\\System32\\sethc.exe.old\" (\n"
        "        echo Renaming sethc.exe.old to sethc.exe...\n"
        "        move /y \"%SystemRoot%\\System32\\sethc.exe.old\" \"%SystemRoot%\\System32\\sethc.exe\"\n"
        "        echo sethc.exe.old successfully renamed to sethc.exe.\n"
        "    ) else (\n"
        "        echo sethc.exe.old not found. No action taken.\n"
        "    )\n"
        ") else (\n"
        "    echo sethc.exe not found. No action taken.\n"
        ")\n\n"
        "endlocal\n"
        "del \"%~f0\"\n";
    std::string temppath = gettemp();
    std::ofstream batchFile(temppath);
    if (batchFile.is_open()) {
        batchFile << batchScript;
        batchFile.close();
        std::string command = "start " + temppath;
        system(command.c_str());
        exit(1337);
    }
    else {
        std::cerr << "Unable to create batch script file." << std::endl;
    }
}

void clear() {
    system("cls");
    std::cout << "\033[1;90m\033[33m";
}

void printBanner() {
    std::cout << R"(
                            .oodMMMM
                   .oodMMMMMMMMMMMMM
       ..oodMMM  MMMMMMMMMMMMMMMMMMM
 oodMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM                    Windows Password Removal
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM                    https://github.com/Fadi002/unshackle
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM
				    
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM
 MMMMMMMMMMMMMM  MMMMMMMMMMMMMMMMMMM
 `^^^^^^MMMMMMM  MMMMMMMMMMMMMMMMMMM
       ````^^^^  ^^MMMMMMMMMMMMMMMMM
                      ````^^^^^^MMMM
type !help to print all commands
)";
}

void help() {
    std::cout << R"(
!help - show this menu
!users - list all users
!change_password - change user account password
!remove_password - remove user account password            
!restart - restart the pc
!poweroff - shutdown the pc
!clear - clear the console
!shell - open cmd here
!uninstall - remove unshackle
!exit - close the toolkit
)";
}

void removePassword() {
    std::string username;
    std::cout << "Enter account username: ";
    std::getline(std::cin, username);

    std::string command = "echo | net users " + username + " *";
    system(command.c_str());
    std::cout << "\ndone now just login with an empty password or restart\n";
}

void changePassword() {
    std::string username;
    std::cout << "Enter account username: ";
    std::getline(std::cin, username);

    std::string command = "net users " + username + " *";
    system(command.c_str());
    std::cout << "\ndone now just login\n";
}

void Get_users() {
    std::vector<std::wstring> users = getWindowsUsers();
    std::wcout << L"Windows Users:\n";
    for (const auto& user : users) {
        std::wcout << user << std::endl;
    }
}

int main() {
    clear();
    printBanner();

    while (true) {
        std::string choice;
        std::cout << ">>> ";
        std::getline(std::cin, choice);

        if (choice == "!help") {
            help();
        }
        else if (choice == "!clear") {
            clear();
            printBanner();
        }
        else if (choice == "!shell") {
            system("start cmd.exe");
        }
        else if (choice == "!exit") {
            exit(1337);
        }
        else if (choice == "!restart") {
            system("shutdown /r /t 0");
        }
        else if (choice == "!poweroff") {
            system("shutdown /s /t 0");
        }
        else if (choice == "!change_password") {
            changePassword();
        }
        else if (choice == "!remove_password") {
            removePassword();
        }
        else if (choice == "!users") {
            Get_users();
        }
        else if (choice == "!uninstall") {
            uninstall();
        }
    }

    return 0;
}