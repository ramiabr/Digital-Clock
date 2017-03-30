`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2017 11:12:42 PM
// Design Name: 
// Module Name: digital_clock
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


module digital_clock(
        clock,
        set,
        incr,
        seg, 
        dp,
        an,
        led,
        date,
        dcr,
        alarm_led
        
    );
    
    parameter time_constant = 28'h5F5E100;
    
    input clock; 
    input set; 
    input incr; 
    input dcr;
    input date;

    // Real Outputs 
    output reg [6:0] seg; 
    output reg [3:0] an;
    output reg dp;
    output reg [7:0] led;
    output alarm_led;
    
    
    //reg set; 
    reg reset; 
    reg [27:0] ATOMIC_TIME = 0;
    reg [27:0] CLOCK_DIVIDER =0;
    
    // Registers that actually holds time 
    reg [4:0] hours_reg = 23;
    reg [5:0] mins_reg = 59; 
    reg [5:0] secs_reg = 55; 
    reg am_pm_reg = 0; 
    reg incr_reg = 0;
    reg dcr_reg = 0;
    reg set_reg = 0;
    reg [2:0] sel_reg = 0;
    reg update_reg = 0;
    reg update_reg_dcr = 0;
    reg [4:0] day = 28;
    reg [3:0] month = 2;
    reg [11:0] year = 12'd2017;
    
    
    
    // Display registers
    reg [6:0] bit0 ; 
    reg [6:0] bit1; 
    reg [6:0] bit2; 
    reg [6:0] bit3;
    
    reg dp_val;
    reg [1:0] date_reg = 0;
    reg [4:0] hours_alarm = 0; 
    reg [5:0] mins_alarm = 0;
    reg set_alarm = 0;
    
    
    // bcd registers 
    wire [3:0] hours_ten_bcd;
    wire [3:0] hours_one_bcd;
    wire [3:0] mins_ten_bcd; 
    wire [3:0] mins_one_bcd;
    wire [3:0] day_10_bcd; 
    wire [3:0] day_1_bcd;
    wire [3:0] month_10_bcd;
    wire [3:0] month_1_bcd;
    wire [3:0] year_1000_bcd, year_100_bcd, year_10_bcd, year_1_bcd;
    wire leap_year;
    wire [3:0] hours_alarm_10, hours_alarm_1, mins_alarm_10, mins_alarm_1;
    wire alarm_signal; 
    
    
    bcd x1 (hours_ten_bcd, hours_one_bcd, hours_reg);
    bcd x2 (mins_ten_bcd, mins_one_bcd, mins_reg);
    
    bcd x3 (month_10_bcd, month_1_bcd, month);
    bcd x4 (day_10_bcd, day_1_bcd, day);
    bcd_1000 x5 (year_1000_bcd, year_100_bcd, year_10_bcd, year_1_bcd, year);
    
    lear_year x6 (year_1000_bcd, year_100_bcd, year_10_bcd, year_1_bcd, leap_year);
    
    bcd x8 (hours_alarm_10, hours_alarm_1, hours_alarm);
    bcd x7 (mins_alarm_10, mins_alarm_1, mins_alarm);
    

    // Trigger alarm 
    assign alarm_led = (hours_alarm == hours_reg ? (mins_reg == mins_alarm ? (set_alarm == 1 ? secs_reg[0] : 0) : 0) : 0) ;
    //assign alarm_led = set_alarm;

    always @ (posedge set) begin 
        sel_reg = sel_reg + 1;
    end
    

    // Clock divider    
    always @ (posedge clock) begin 
        CLOCK_DIVIDER = CLOCK_DIVIDER + 1;
    end
    
    // Time Keeping service 
    always @ (posedge clock) begin
            if(date == 1) begin
                set_alarm = 0;
            end
            
            if(incr == 0) begin 
                update_reg = 0;
                date_reg = 0;
            end
                
            if(sel_reg != 3'b000 && incr == 1 && update_reg == 0) begin
                incr_reg = 1;
                update_reg = 1;
            end
            
            
            if(dcr == 0) begin 
                update_reg_dcr = 0;
                date_reg = 0;
            end
            
            if(sel_reg != 3'b000 && dcr == 1 && update_reg_dcr == 0) begin
                 dcr_reg = 1;
                 update_reg_dcr = 1;
            end
    
            if(ATOMIC_TIME < time_constant) begin
               ATOMIC_TIME = ATOMIC_TIME + 1;     
            end   
            else begin  
                ATOMIC_TIME = 0;
            end    
    
        // Works as Clock
        if(sel_reg == 3'b000 || sel_reg == 3'b110 || sel_reg == 3'b111) begin             
            if(ATOMIC_TIME == 0) begin
                // Increment Time
                if(secs_reg < 59) begin 
                    secs_reg = secs_reg + 1;
                end
                else begin 
                    secs_reg = 0; 
                
                    if(mins_reg < 59)  
                        mins_reg = mins_reg + 1;
                 
                    else begin
                        mins_reg = 0; 
                    
                        if(hours_reg < 23) begin 
                            hours_reg = hours_reg + 1;
                        end
                        else begin 
                            hours_reg = 0; 
                            //am_pm_reg = ~ am_pm_reg;
                            
                            //if(am_pm_reg == 1'b1) begin 
                                day = day + 1;
                                
                                
                                // incr month according to day
                                if(day == 0) begin 
                                    if(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10) begin 
                                        month = month + 1;
                                   
                                   end else if (month == 12) begin 
                                        month = 1; 
                                        day = 1; 
                                        year = year + 1;                                   
                                   end  else 
                                        month = month;
                                        
                                end else if (day == 31) begin 
                                    if(month == 4 || month == 6 || month == 9 || month == 11) begin 
                                        month = month + 1;
                                        day = 1;                                    
                                    end else 
                                        month = month; 
                                                                                                       
                                end else if(leap_year == 0 && day == 29 && month == 2) begin 
                                    month = month + 1;
                                    day = 1;
                                end else if(leap_year == 1 && day == 30 && month == 2) begin 
                                    month = month + 1;
                                    day = 1;                                
                                end else 
                                    month = month;
                                


                                if(day == 0)
                                    day = 1;
                        end
                    end             
                end 
            end
        end     
        // Setting hours
        else if(sel_reg == 3'b001) begin             
            if(incr_reg == 1'b1) begin 
                incr_reg = 0;   
                hours_reg = hours_reg + 1;  
                secs_reg = 0; 

                if(hours_reg > 23) begin 
                    hours_reg = 0;
                end                                                           
            end 
            else if(dcr_reg == 1'b1) begin 
                dcr_reg = 0;
                hours_reg = hours_reg - 1;
                secs_reg = 0;
                
                if(hours_reg == 5'b11111) 
                    hours_reg = 23;             
            end       
        end   
        // Setting Mins
        else if(sel_reg == 3'b010) begin             
            if(incr_reg == 1'b1) begin 
                incr_reg = 0;   
                mins_reg = mins_reg + 1;  
                secs_reg = 0; 

                if(mins_reg > 59) begin 
                    mins_reg = 0;
                end                                                           
            end 
            else if(dcr_reg == 1'b1) begin 
                dcr_reg = 0;
                mins_reg = mins_reg - 1;
                secs_reg = 0;
                
                if(mins_reg == 6'b111111)
                    mins_reg = 59;            
            end       
        end   
        // Setting Mins
        else if(sel_reg == 3'b100) begin    
            date_reg = 1;         
            if(incr_reg == 1'b1) begin 
                incr_reg = 0;   
                day = day + 1;  
                
                if(day > 31 || day == 0)  
                    day = 1;

                
             end
             else if(dcr_reg == 1'b1) begin 
                dcr_reg = 0;
                day = day - 1;
                
                if(day == 0)
                    day = 31;                           
             end
        end 
        else if(sel_reg == 3'b011) begin   
                date_reg = 1;                  
                if(incr_reg == 1'b1) begin 
                    incr_reg = 0;   
                    month = month + 1;  
                    if(month > 12) begin
                        month = 1;    
                    end
                end
                else if (dcr_reg == 1'b1) begin 
                    dcr_reg = 0; 
                    month = month -1 ;
                    
                    if(month == 0) 
                        month = 12 ;                
                end                        
        end 
        else if(sel_reg == 3'b101) begin 
                date_reg = 2;                    
                if(incr_reg == 1'b1) begin 
                    incr_reg = 0;   
                    year = year + 1;  
                end
                else if(dcr_reg == 1'b1) begin 
                    dcr_reg = 0; 
                    year = year - 1;               
                end 
         end
         
         
         if(sel_reg == 3'b110) begin                
                if(incr_reg == 1'b1) begin 
                    set_alarm = 1;
                    incr_reg = 0;
                    hours_alarm = hours_alarm + 1;
                    
                    if(hours_alarm > 23) begin 
                        hours_alarm = 0;
                    end                    
                end else if(dcr_reg == 1'b1) begin 
                    set_alarm = 1;
                    dcr_reg = 0;
                    hours_alarm = hours_alarm -1; 
                    
                       if(hours_alarm == 5'b11111) 
                        hours_reg = 23; 
                end
         end 
         else if(sel_reg == 3'b111) begin          
            if(incr_reg == 1'b1) begin 
                set_alarm = 1;
                incr_reg = 0;
                mins_alarm = mins_alarm + 1;
                
                if(mins_alarm > 59) 
                    mins_alarm = 0;
            end else if(dcr_reg == 1'b1) begin 
                set_alarm = 1;
                dcr_reg = 0;
                mins_alarm = mins_alarm - 1;
                
                if(mins_alarm  == 6'b111111)
                    mins_reg = 59;
            end         
         end
    end

    //reg [3:0] hours_hund_bcd;
    //reg [3:0] hours_ten_bcd;
    
   
  
   task drive_7seg; 
    output [6:0] bit;
    input [5:0] bcd;
    
        begin 
        case(bcd) 
         6'd0: begin
            bit [6:0] = 7'b1000000;
        end
        6'd1: begin
            bit [6:0] = 7'b1111001;
       end
        6'd2: begin
            bit [6:0] = 7'b0100100;
       end
        6'd3: begin
            bit [6:0] = 7'b0110000;
       end
        6'd4: begin
            bit [6:0] = 7'b0011001;
       end
        6'd5: begin
            bit [6:0] = 7'b0010010;
       end
        6'd6: begin
            bit [6:0] = 7'b0000010;
       end
        6'd7: begin
            bit [6:0] = 7'b1111000;
       end
        6'd8: begin
            bit [6:0] = 7'b0000000;
       end
        6'd9: begin
            bit [6:0] = 7'b0010000;
       end
        default: begin 
        bit [6:0] = 7'b0111111;
        end
    endcase       
        end
   
   endtask 
    
    // Assign the output to display    
    always @ *  begin 
    
        dp_val = 1'b1;  
        if(date_reg == 1 || date_reg == 2) begin 
            // Calculate the display bits for hours 
            if(date_reg == 1) begin 
                drive_7seg(bit2, month_1_bcd);
                drive_7seg(bit3, month_10_bcd); 
                drive_7seg(bit0, day_1_bcd);
                drive_7seg(bit1, day_10_bcd);
                dp_val = 1'b0;
            end 
            else begin                            
                drive_7seg(bit3, year_1000_bcd);
                drive_7seg(bit2, year_100_bcd);
                drive_7seg(bit1, year_10_bcd);
                drive_7seg(bit0, year_1_bcd);
                dp_val = 1'b1;                
            end
           
            if(ATOMIC_TIME[19:18] == 2'b00) begin   
                seg[6:0] = bit0; 
                an[3:0]  = 4'b1110;      
                dp = 1'b1;      

            end
            if(ATOMIC_TIME[19:18] == 2'b01) begin   
                seg[6:0] = bit1; 
                an[3:0]  = 4'b1101;
                dp = 1'b1;
            end
            if(ATOMIC_TIME[19:18] == 2'b10) begin   
                seg[6:0] = bit2; 
                an[3:0]  = 4'b1011;   
                dp = dp_val;         
            end
            if(ATOMIC_TIME[19:18] == 2'b11) begin   
                seg[6:0] = bit3; 
                an[3:0]  = 4'b0111;
                dp = 1;
            end       
        end 
        else if(date == 1'b1) begin 
            // Calculate the display bits for hours 
            if(secs_reg[1:0] == 2'b00 || secs_reg[1:0] == 2'b01) begin 
                drive_7seg(bit2, month_1_bcd);
                drive_7seg(bit3, month_10_bcd); 
                drive_7seg(bit0, day_1_bcd);
                drive_7seg(bit1, day_10_bcd);
                dp_val = 1'b0;
            end 
            else begin                            
                drive_7seg(bit3, year_1000_bcd);
                drive_7seg(bit2, year_100_bcd);
                drive_7seg(bit1, year_10_bcd);
                drive_7seg(bit0, year_1_bcd);
                dp_val = 1'b1;                
            end
           
            if(ATOMIC_TIME[19:18] == 2'b00) begin   
                seg[6:0] = bit0; 
                an[3:0]  = 4'b1110;      
                dp = 1'b1;      

            end
            if(ATOMIC_TIME[19:18] == 2'b01) begin   
                seg[6:0] = bit1; 
                an[3:0]  = 4'b1101;
                dp = 1'b1;
            end
            if(ATOMIC_TIME[19:18] == 2'b10) begin   
                seg[6:0] = bit2; 
                an[3:0]  = 4'b1011;   
                dp = dp_val;         
            end
            if(ATOMIC_TIME[19:18] == 2'b11) begin   
                seg[6:0] = bit3; 
                an[3:0]  = 4'b0111;
                dp = 1;
            end       
        end 
        else if (sel_reg == 3'b110 || sel_reg == 3'b111) begin 
             // Calculate the display bits for hours 
            drive_7seg(bit2, hours_alarm_1);
            drive_7seg(bit3, hours_alarm_10);
            drive_7seg(bit0, mins_alarm_1);
            drive_7seg(bit1, mins_alarm_10);

            if(ATOMIC_TIME[19:18] == 2'b00) begin   
                seg[6:0] = bit0; 
                an[3:0]  = 4'b1110;      
                dp = 1;      
            end
            if(ATOMIC_TIME[19:18] == 2'b01) begin   
                seg[6:0] = bit1; 
                an[3:0]  = 4'b1101;
                dp = 1;
            end
            if(ATOMIC_TIME[19:18] == 2'b10) begin   
                seg[6:0] = bit2; 
                an[3:0]  = 4'b1011;   
                dp = 0;         
            end
            if(ATOMIC_TIME[19:18] == 2'b11) begin   
                seg[6:0] = bit3; 
                an[3:0]  = 4'b0111;
                dp = 1;
            end
        end
        else begin             
            // Calculate the display bits for hours 
            drive_7seg(bit2, hours_one_bcd);
            drive_7seg(bit3, hours_ten_bcd);
            drive_7seg(bit0, mins_one_bcd);
            drive_7seg(bit1, mins_ten_bcd);

            if(ATOMIC_TIME[19:18] == 2'b00) begin   
                seg[6:0] = bit0; 
                an[3:0]  = 4'b1110;      
                dp = 1;      
            end
            if(ATOMIC_TIME[19:18] == 2'b01) begin   
                seg[6:0] = bit1; 
                an[3:0]  = 4'b1101;
                dp = 1;
            end
            if(ATOMIC_TIME[19:18] == 2'b10) begin   
                seg[6:0] = bit2; 
                an[3:0]  = 4'b1011;   
                dp = 0;         
            end
            if(ATOMIC_TIME[19:18] == 2'b11) begin   
                seg[6:0] = bit3; 
                an[3:0]  = 4'b0111;
                dp = 1;
            end
        end
    end
    
    
    // LED to display the time selected for updation
    always @ * begin 
        case(sel_reg) 
            3'd0:  led = 8'b00000001;
            3'd1:  led = 8'b00000010; 
            3'd2:  led = 8'b00000100; 
            3'd3:  led = 8'b00001000; 
            3'd4:  led = 8'b00010000; 
            3'd5:  led = 8'b00100000;
            3'd6:  led = 8'b01000000;
            3'd7:  led = 8'b10000000;  
            default: led = 8'b00000000;
           endcase  
    end
    
endmodule


module bcd(ten, one, bin);
    input [5:0] bin; 
    output reg [3:0] ten, one;
    integer i;
    
    
    always @ (*) begin 
        ten = 4'd0;
        one = 4'd0;
        
        for(i=5; i>=0; i=i-1) begin 
            if(ten >= 4'd5)
                ten = ten + 4'd3;
            if(one >= 4'd5)
                one = one + 4'd3;
                
            ten = ten << 1;
            ten[0] = one[3]; 
            one = one << 1;
            one[0] = bin[i];
        end
    end
endmodule




module bcd_1000(thousand, hundred, ten, one, bin);
    input [11:0] bin; 
    output reg [3:0] thousand, hundred, ten, one;
    integer i;
    
    
    always @ (*) begin 
        thousand = 4'd0;
        hundred = 4'd0;         
        ten = 4'd0;
        one = 4'd0;
        
        for(i=11; i>=0; i=i-1) begin 
            if(thousand >= 5)
                thousand = thousand + 3;
            if(hundred >= 5)
                hundred = hundred + 3;
            if(ten >= 4'd5)
                ten = ten + 4'd3;
            if(one >= 4'd5)
                one = one + 4'd3;
            
            thousand = thousand << 1; 
            thousand[0] = hundred[3]; 
            hundred = hundred << 1; 
            hundred[0] = ten[3]; 
            ten = ten << 1;
            ten[0] = one[3]; 
            one = one << 1;
            one[0] = bin[i];
        end
    end
endmodule

module lear_year (year_1000, year_100, year_10, year_1, leap_year);
    input [3:0] year_1000, year_100, year_10, year_1; 
    output leap_year;
    reg div_by_4;
    wire div_by_100, div_by_400;
    
    // Divisible by 4 
    always @ (*) begin 
        if(year_10[0])
            div_by_4 = (year_1[3:0] == 4'h2) | (year_1[3:0] == 4'h6);
        else 
            div_by_4 = (year_1[3:0] == 4'h0) | (year_1[3:0] == 4'h4) | (year_1[3:0] == 4'h8);    
    end
    
    assign div_by_100 = (year_10[3:0] == 4'h0) & (year_1[3:0] == 4'h0);
    assign div_by_400 = div_by_4 & div_by_100;
    
    assign leap_year = div_by_4 & (~div_by_100) | div_by_400; 

endmodule

