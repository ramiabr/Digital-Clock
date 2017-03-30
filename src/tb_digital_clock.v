`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2017 01:07:57 PM
// Design Name: 
// Module Name: tb_digital_clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_digital_clock; 

    reg clock; 
    reg set;
    reg incr;
    reg date;
    
    wire [4:0] hours;
    wire [5:0] mins;
    wire [5:0] secs; 
    wire [4:0] day;
    wire [3:0] month; 
    wire [11:0] year;
    
    wire [6:0] seg;
    wire dp; 
    wire [3:0] an;
    wire [5:0] led;
    reg dcr; 
    wire alarm;
    integer i;
    integer j;

    
    digital_clock x1 (clock, set, incr, seg, dp, an, led, date, dcr, alarm,  hours, mins, secs, day, month, year);
    
    
    always begin 
      #2  clock = ~ clock;
    end
    
    
    initial begin 
        clock = 0; set = 0; incr =0;      date = 0;  dcr = 0; 
        
        
        for(j = 1; j < 8; j = j + 1) begin 
            
            // Set Hours 
            set_button(0, j);
            
            
            incr_t(3);
            
            
            dcr_t(1);

            
            set_button(j, 8);
            
            #10;
            
                    
        end
        
        
        //#500 
        //date = 1;
        
        
        #100 $finish;
    end


    task set_button; 
        input [3:0] start_set, end_point_set;
        integer i;
        
        for(i = start_set; i < end_point_set; i = i + 1) begin 
            #4
            set = 1;
            
            #2
            set = 0;        
        end
    endtask
    
    
    task incr_t; 
        input [2:0] end_point;
        integer i;
        
        for(i = 0; i < end_point; i = i +1) begin 
            #4 
            incr = 1;
            
            #4
            incr  = 0;
        end
    endtask

    task dcr_t; 
        input [2:0] end_point;
        integer i;
        
        for(i = 0; i < end_point; i = i +1) begin 
            #4 
            dcr = 1;
            
            #4
            dcr  = 0;
        end
    endtask


endmodule
