/***************************************************************************
 *   Copyright (C) 2005 by Curtis Monroe                                   *
 *   curtis@pccurtis.rytis.com                                             *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <strings.h>
#include <unistd.h>

/* baudrate settings are defined in <asm/termbits.h>, which is included by <termios.h> */
/* change this definition for the correct port */

#define MODEMDEVICE "/dev/ttyS0"

#define _POSIX_SOURCE 1 /* POSIX compliant source */

#define FALSE 0
#define TRUE 1

#define LINE_LENGTH 120

//=============================================================================
unsigned char ReadByte(int fd, const int wait_seconds)
{
	fd_set readfs;    // file descriptor set
	struct timeval tv;
        int maxfd = fd+1;  // maximum bit entry (fd) to test
        
	FD_ZERO(&readfs);
        FD_SET(fd, &readfs);  // set testing for source 1
        
	tv.tv_sec = wait_seconds;
        tv.tv_usec = 0;

	// block until input becomes available or timeout is reached,

	int retval = pselect(maxfd, &readfs, NULL, NULL, &tv, NULL);
	if (retval == -1)
        {
		perror("select()");
	}
        else if (retval)
	{
	        assert(FD_ISSET(fd, &readfs));       	
		//printf("Data is available now.\n");
		unsigned char ch;
		if(read(fd, &ch, 1) > 0)	/* returns after 1 chars have been input */
		{
			return(ch);
		}
		else
		{
			perror("read()");
			exit(-1);
		}	
        }       
        else
        {
		printf("ReadByte ERROR, no input after %d seconds\n\n", wait_seconds);
		exit(-1);
	}
}

//=============================================================================
void WriteByte(int fd, unsigned char ch, int flush)
{
	int res;

	res = write(fd, &ch, 1);
	if(res != 1)
	{
		perror("write()");
		printf("WriteByte ERROR, \n\n");
		exit(-1);
	}

	if( flush )
	{
		tcdrain(fd);
	}	
}


//=============================================================================
void WaitForChar(int fd, const char expected_char, const int wait_seconds)
{
	unsigned char ch;
	ch = ReadByte(fd, wait_seconds);

	if(expected_char == ch) 
	{
		return;
	}
	else
	{
		printf("ERROR!!! Expected '%c' but found '%c'\n", expected_char, ch);
		exit(-1);
	}
}

//=============================================================================
void WriteWord(int fd, unsigned int word, int flush)
{
	WriteByte(fd, (unsigned char)(word), FALSE);
	WriteByte(fd, (unsigned char)(word>>8), FALSE);
	WriteByte(fd, (unsigned char)(word>>16), FALSE);
	WriteByte(fd, (unsigned char)(word>>24), flush);
}

//=============================================================================
unsigned int ReadWord(int fd, const int wait_seconds)
{
	unsigned int word=0;

	word = (word<<8)|ReadByte(fd, wait_seconds);
	word = (word<<8)|ReadByte(fd, wait_seconds);
	word = (word<<8)|ReadByte(fd, wait_seconds);
	word = (word<<8)|ReadByte(fd, wait_seconds);

	return(word);
}

//=============================================================================
void OutputFile(int fd, const char* file_name, const int num_bytes, int bverbose)
{
	char ch;
	int fd_bin;
	int x;
	int res;
	int out_count = 0;
	time_t start_time = time(NULL);
	
	fd_bin = open(file_name, O_RDONLY);
	if (fd_bin <0) {perror(file_name); exit(-1); }
	
	for(x=0; x<num_bytes; x++)
	{
		res = read(fd_bin, &ch, 1);
		if(res == 1)
		{
			if(bverbose)
			{
				printf("%0.2x", (unsigned char	)ch);
				fflush(stdout);
				out_count += 2;

				WriteByte(fd, ch, TRUE);
			}
			else 
			{
				if((x%1024) == 0)
				{
					printf(".");
					fflush(stdout);
					out_count++;
				}

				WriteByte(fd, ch, ((x%1024) == 0) );
			}

			if(out_count >= LINE_LENGTH) 
			{
				printf("\n");
				out_count = 0;
			}

		}
		else
		{
			perror(file_name);
			exit(-1);
		}

	}

	printf("\n");
	printf("%d Bytes in %d seconds.\n", num_bytes, (time(NULL)-start_time));

	close(fd_bin);
}

//=============================================================================
void SendFileToTS72XX(int fd, const char* file_name)
{
	//unsigned int length = ReadWord(fd);
	unsigned int fd_bin;
	int length;

	fd_bin = open(file_name, O_RDONLY);
	if (fd_bin <0) {perror(file_name); exit(-1); }

	length = lseek(fd_bin, 0, SEEK_END);

	close(fd_bin);	

	printf("\n");
	printf("length=%d\n", length);
	assert(length>0);
	assert(length%4 == 0);
	assert(length<256*1024); // sanity check
	WriteWord(fd, length, TRUE);

	printf("waiting length acknowledgement '@'\n");
	WaitForChar( fd, '@', 10);
	printf("found '@'\n");	

	printf("--------- SENDING FILE \"%s\" ---------\n", file_name);


	OutputFile(fd, file_name, length, FALSE);
	
	printf("--------------------------------------------------\n");
	printf("\n");

	printf("waiting for ']'\n");
	WaitForChar( fd, ']', 10);
	printf("found ']'\n");	
}

//=============================================================================
void DumpMemoryRangeFromTS72XX(int fd)
{
	unsigned int start = ReadWord(fd, 10);
	unsigned int end   = ReadWord(fd, 10);
	
	printf("\n");
	printf("--------- MEM DUMP 0x%0.8x-0x%0.8x ---------\n", start, end);
	assert(start < end);
	
	unsigned int addr;
	for(addr=start; addr<=end; addr+=4)
	{
		printf("[0x%0.8x] = 0x%0.8x\n", addr, ReadWord(fd, 10));		
	}
 	printf("--------------------------------------------------\n");
	printf("\n");
	
}

//=============================================================================
void DumpMemoryFromTS72XXToFile(int fd, const char* file_name)
{
	int fd_bin;
	int res;
	
	unsigned int start = ReadWord(fd, 10);
	unsigned int end   = ReadWord(fd, 10);
	
	printf("\n");
	printf("--------- MEM DUMP TO FILE 0x%0.8x-0x%0.8x ---------\n", start, end);
	assert(start < end);
	
	fd_bin = open(file_name, O_RDWR | O_CREAT | O_TRUNC);
	if (fd_bin <0) {perror(file_name); exit(-1); }
	
	unsigned int addr;
	for(addr=start; addr<=end; addr+=4)
	{
		unsigned int word = ReadWord(fd, 10);
		//unsigned char tmp[4];
		
		printf(".");
		//printf("[0x%0.8x] = 0x%0.8x\n", addr, ReadWord(fd));
		//tmp[0] = ((unsigned char *)&word)[3];
		//tmp[1] = ((unsigned char *)&word)[2];
		//tmp[2] = ((unsigned char *)&word)[1];
		//tmp[3] = ((unsigned char *)&word)[0];
		
		//res = write(fd_bin, &tmp, 4);
		res = write(fd_bin, &word, 4);
		
		assert(res==4);
	}
 	printf("--------------------------------------------------\n");
	printf("\n");

	close(fd_bin);	
}

//=============================================================================
void ShowResponse(int fd, const int wait_seconds)
{
	int quit=FALSE;
	char ch;
	int res;
	time_t start_time = time(NULL);
	
	for(;;)  // exit after wait_seconds
	{
		ch = ReadByte(fd, wait_seconds);
		if(isprint(ch) || ch=='\r' || ch=='\n')
		{
			printf("%c", ch);
		}
		else
		{
			printf(".");
		}

		if((time(NULL)-start_time) >= 10)
		{
			printf("exiting after %d seconds\n\n", (time(NULL)-start_time));
			break;
		}
        }
}

//=============================================================================
void ShowOutput(int fd, const int wait_seconds)
{
	int quit=FALSE;
	char ch;
//	int res;
	time_t start_time = time(NULL);
	
	while (!quit)  // exit after wait_seconds
	{
//		res=read(fd, &ch, 1);
		ch = ReadByte(fd, wait_seconds);
//		if(res > 0)
//		{
			printf("%c", ch);
			fflush(stdout);
//		}

		if((time(NULL)-start_time) >= 90)
		{
			printf("exiting after %d seconds\n\n", (time(NULL)-start_time));
			break;
		}

        }
}


//=============================================================================
void ProcessRequests(int fd, const int wait_seconds)
{
	int quit=FALSE;
	char ch;
	int res;
	time_t start_time = time(NULL);
	
	while (!quit)  // exit after wait_seconds
	{
		ch = ReadByte(fd, wait_seconds);
		if(ch == '\0')
		{
			// dump one word
			printf("0x%0.8x\n", ReadWord(fd, 10));
			fflush(stdout);
		}
		else if(ch == '\1')
		{
			DumpMemoryRangeFromTS72XX(fd);
		}
		else if(ch == '\2')
		{
			DumpMemoryFromTS72XXToFile(fd, "rom.bin");
		}
		else if(ch == '\3')
		{
			//SendFileToTS72XX(fd, "boot2.bin");
			SendFileToTS72XX(fd, "redboot.bin");
			ShowOutput(fd, 10);
		}
		else
		{
			printf("%c", ch);
			fflush(stdout);
		}

		if((time(NULL)-start_time) >= 90)
		{
			printf("exiting after %d seconds\n\n", (time(NULL)-start_time));
			break;
		}

        }
}

//=============================================================================
void RequestEP93XXSerialTest(int fd )
{
	printf("waiting for '<'\n");
	WaitForChar( fd, '<', 10);
	printf("found '<'\n");		

	// command to send ASCII sequence (repeated till TS watchdog reboots):
	unsigned char ch[4]="UART"; 
	write(fd, ch, 4);

	ShowResponse(fd, 10); // to output the results
}

//=============================================================================
void GetEP93XXAboutInfo(int fd )
{
	printf("waiting for '<'\n");
	WaitForChar( fd, '<', 10);
	printf("found '<'\n");		

	 // to see the Nexus team members  (repeated till TS watchdog reboots):
	unsigned char ch[4]="UANT";
	write(fd, ch, 4);

	ShowResponse(fd, 10); // to output the results
}

//=============================================================================
void BootFromFileAndProcessRequests(int fd, const char* file_name, struct termios* pnewtio )
{

	printf("waiting for '<'\n");
	WaitForChar( fd, '<', 10);
	printf("found '<'\n");		

	printf("\n");
	printf("--------- SENDING 2K BOOT FILE: \"%s\" ---------\n", file_name);
//	OutputFile(fd, "ts-preboot-ts9.bin", 2048, TRUE);
//	OutputFile(fd, "boot.bin", 2048, TRUE);
	OutputFile(fd, file_name, 2048, TRUE);
 	printf("--------------------------------------------------\n");
	printf("\n");

	printf("waiting for '>'\n");
	WaitForChar( fd, '>', 10);
	printf("found '>'\n");	

        tcflush(fd, TCIFLUSH);
	cfsetospeed(pnewtio, B115200);
	cfsetispeed(pnewtio, B115200);
	tcsetattr(fd,TCSANOW,pnewtio);
        tcflush(fd, TCIFLUSH);

	ProcessRequests(fd, 10);
}

//=============================================================================
int main(int argc, char *argv[])
{
	int fd;
        struct termios oldtio,newtio;
	
	printf("START\n");
		
        fd = open(MODEMDEVICE, O_RDWR | O_NOCTTY | O_NONBLOCK); 
        if (fd <0) {perror(MODEMDEVICE); exit(-1); }
        
        tcgetattr(fd,&oldtio); /* save current port settings */
        
        bzero(&newtio, sizeof(newtio));
        newtio.c_cflag = B9600 | CRTSCTS | CS8 | CLOCAL | CREAD;
        newtio.c_iflag = IGNPAR;
        newtio.c_oflag = 0;
        
        /* set input mode (non-canonical, no echo,...) */
        newtio.c_lflag = 0;
         
        newtio.c_cc[VTIME]    = 0;   /* inter-character timer unused */
        newtio.c_cc[VMIN]     = 1;   /* blocking read until 5 chars received */
        
	cfmakeraw(&newtio);
        tcflush(fd, TCIFLUSH);
        tcsetattr(fd,TCSANOW,&newtio);

//	GetEP93XXAboutInfo(fd);
//	RequestEP93XXSerialTest(fd);
//	BootFromFileAndProcessRequests(fd, "ts-preboot-ts9.bin", &newtio );
	BootFromFileAndProcessRequests(fd, "boot.bin", &newtio );
	
        tcsetattr(fd,TCSANOW,&oldtio);
   
	return EXIT_SUCCESS;
}
