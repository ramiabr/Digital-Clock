                              Clock and Calendar System using Xilinx Artix-7 (Basys 3 Board)
                              
                              
In this project a clock and calendar system is realized using Artix-7 in Basys 3 board. The system keeps track of date and time; its primary input is 10MHZ clock along with optional switches to set date and time. The system increments a 28-bit register every clock cycle, once the counter reaches count of 100,000,000 it means 1 second has elapsed, so the device updates seconds, minutes, hours and date accordingly. Based on the current year the calendar calculates if it’s a leap year. Since modulus is costly to realize in hardware, the leap year tracker is implemented without modulus. The LED’s present in the Basys 3 board have been configured to tells us about the current state of the state machine. Since there are only 4-digits in hexadecimal display in Basys3 board the code is implemented in such a way that calendar is displayed when user pushes a date button and the month and day are multiplexed between year forming like a flashing display. The system also features an alarm clock which can be set by the user and the alarm flashes a LED light, it can be switched off by clicking date button. This system has been completely tested with both simulation vectors and real time in FPGA.     




                              
                             
