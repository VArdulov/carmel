#ifndef OS_HPP
#define OS_HPP

#if !defined( BOOST_IO_WINDOWS ) && !defined( BOOST_IO_POSIX )
# if defined(_WIN32) || defined(__WIN32__) || defined(WIN32) || defined(__CYGWIN__)
#  define BOOST_IO_WINDOWS
#  ifndef _WIN32_WINNT
#   define _WIN32_WINNT 0x0500
#  endif
# else
#  define BOOST_IO_POSIX
# endif
#endif


#ifdef BOOST_IO_WINDOWS
# define WIN32_LEAN_AND_MEAN  // Exclude rarely-used stuff from Windows headers
# include <windows.h>
 typedef DWORD Error;
#else
# include <errno.h>
# include <string.h>
 typedef int Error;
#endif

#include <string>
#include <cstdio>


Error last_error() {
#ifdef BOOST_IO_WINDOWS
    return ::GetLastError();
#else
    return errno;
#endif
}

#include <stdexcept>
std::string error_string(Error err) {
#ifdef BOOST_IO_WINDOWS
    LPVOID lpMsgBuf;
    if (::FormatMessage(
            FORMAT_MESSAGE_ALLOCATE_BUFFER |
            FORMAT_MESSAGE_FROM_SYSTEM,
            NULL,
            err,
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            (LPTSTR) &lpMsgBuf,
            0, NULL ) == 0)
        throw std::runtime_error("couldn't generate Windows error message string");
    std::string ret((LPTSTR) lpMsgBuf);
    ::LocalFree(lpMsgBuf);
    return ret;
#else
    return strerror(err);
#endif
}

std::string last_error_string() {
    return error_string(last_error());
}


bool create_file(const std::string& path,std::size_t size) {
#ifdef _WIN32
#if 0
    //VC++ only, unfortunately
    int fd=::_open(path.c_str(),_O_CREAT|_O_SHORT_LIVED);
    if (fd == -1)
        return false;
    if (::_chsize(fd,size) == -1)
        return false;
    return ::_close(fd) != -1;
#else
    HANDLE fh=::CreateFileA( path.c_str(),GENERIC_WRITE,FILE_SHARE_DELETE,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_TEMPORARY,NULL);
    if (fh == INVALID_HANDLE_VALUE)
        return false;
    if(::SetFilePointer(fh,size,NULL,FILE_BEGIN) != size)
        return false;
    if (!::SetEndOfFile(fh))
        return false;
    return ::CloseHandle(fh);
#endif
#else
    return ::truncate(path.c_str(),size) != -1;
#endif
}

bool remove_file(const std::string &filename) {
    return 0==remove(filename.c_str());
}

//#include <stdio.h>

#include <fstream>
struct tmp_fstream
{
    std::string filename;
    std::fstream file;
    bool exists;
    explicit tmp_fstream(const char *c)
    {
        choose_name();
        open();
        file << c;
        reopen();
    }
    tmp_fstream(std::ios::openmode mode=std::ios::in | std::ios::out | std::ios::trunc )
    {
        choose_name();
        open(mode);
    }
    void choose_name()
    {
        filename=std::tmpnam(NULL);
    }
    void open(std::ios::openmode mode=std::ios::in | std::ios::out | std::ios::trunc) {
        file.open(filename.c_str(),mode);
        if (!file)
            throw std::ios::failure(std::string("couldn't open temporary file ").append(filename));
    }
    void reopen()
    {
        file.flush();
        file.seekg(0);
    }
    void close()
    {
        file.close();
    }
    void remove()
    {
        remove_file(filename);
    }

    ~tmp_fstream()
    {
        close();
        remove();
    }
};



#endif
