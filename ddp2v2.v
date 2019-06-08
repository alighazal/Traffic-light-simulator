//DD_p2 Module 

`timescale 1ns / 1ps
module dd_p2 (input clk, input sensor, input walk_request1, input walk_request2 ,input walk_request3, input walk_request4, input rst,
output reg main_G,output reg main_Y, output reg main_R, output reg side_G, output reg side_Y, output reg side_R, output reg  walk_signal, output reg jam_exists);

    reg [27:0] count=0;
    wire clk_enable; 
    wire slow_clk;
    wire walk_d1, walk_d2, walk_d3, walk_d4;
   
    debouncer D1(clk,rst,walk_d1,walk_request1);
    debouncer D2(clk,rst,walk_d2,walk_request2);
    debouncer D3(clk,rst,walk_d3,walk_request3);
    debouncer D4(clk,rst,walk_d4,walk_request4);
    
    Clock_Divider cd(clk, rst, slow_clk);
    
    parameter mG_sR = 3'b000, mY_sR = 3'b001, mR_sR1 = 3'b010, mR_sR2 = 3'b101, mR_sG = 3'b011, mR_sY = 3'b100;
      
    reg[2:0] state, next_state;
    
    wire walk_sig;
    reg walk = 0;
    reg en1 = 0, en2 = 0, en3 = 0, en4 = 0, en5 = 0, en6 = 0;
    reg d1 = 0, d2 = 0, d3 = 0, d4 = 0,  d5 = 0, d6 = 0;

    
    // FSM
    always @(posedge clk or posedge rst)
    begin
    
        if (walk_d1|| walk_d2 || walk_d3 ||  walk_d4)  
            walk = 1; 
            
                  
        case(state)
        mG_sR:
        begin
        
        en1 <= 1; en2 <= 0 ;en3 <= 0; en4 <= 0; en5 <= 0; en6 <= 0;

            //assigning colors to street
              main_G <= 1;
              main_Y <= 0;
              main_R <= 0;
              side_G <= 0;
              side_Y <= 0;
              side_R <= 1;
              walk_signal = 0;
            
              if (d1) 
                next_state= mY_sR; 
        end
        
        mY_sR: 
        begin
            
           en1 <= 0; en2 <= 1 ;en3 <= 0; en4 <= 0; en5 <= 0; en6 <= 0;

            //assigning colors to street
           main_G <= 0;
           main_Y <= 1;
           main_R <= 0;
           side_G <= 0;
           side_Y <= 0;
           side_R <= 1;
           walk_signal = 0;

           if (d2)
           begin
              if (walk) next_state = mR_sR1;
              else  next_state = mR_sG;
                 
           end 
        end
        
        mR_sR1: 
        begin
             en1 <= 0; en2 <= 0 ;en3 <= 1; en4 <= 0; en5 <= 0; en6 <= 0;
             walk <= 0; 
                
            //assigning colors to street
            main_G <= 0;
            main_Y <= 0;
            main_R <= 1;
            side_G <= 0;
            side_Y <= 0;
            side_R <= 1;
            walk_signal = 1;
            
            if (d3) 
                next_state = mR_sG;
  
        end
                     
            mR_sG:
            begin
                en1 <= 0; en2 <= 0 ;en3 <= 0; en4 <= 1; en5 <= 0; en6 <= 0;
                
                //assigning colors to street
                main_G <= 0;
                main_Y <= 0;
                main_R <= 1;
                side_G <= 1;
                side_Y <= 0;
                side_R <= 0;
                walk_signal = 0;

                if (d4)
                    next_state = mR_sY;
          
            end
            
            
            mR_sY: 
            begin
                 en1 <= 0; en2 <= 0 ;en3 <= 0; en4 <= 0; en5 <= 1; en6 <= 0;
                //assigning colors to street
                  main_G <= 0;
                  main_Y <= 0;
                  main_R <= 1;
                  side_G <= 0;
                  side_Y <= 1;
                  side_R <= 0;
                  walk_signal = 0;

               if (d5) 
               begin
            
                  if (walk) 
                    next_state = mR_sR2;
                  else 
                    next_state = mG_sR;
               end 
        end
        
        mR_sR2: 
        begin
            en1 <= 0; en2 <= 0 ;en3 <= 0; en4 <= 0; en5 <= 0; en6 <= 1;
            walk <= 0;
            
            //assigning colors to street
              main_G <= 0;
              main_Y <= 0;
              main_R <= 1;
              side_G <= 0;
              side_Y <= 0;
              side_R <= 1;
              walk_signal = 1;

              if (d6) 
                next_state = mG_sR;

        end
        
        
        default: 
            begin
                en1<=0; en2<=0 ;en3<=0; en4<=0; en5<=0; en6 <=0;
                next_state =  mG_sR;
            end

        endcase
        
              if(rst)
              begin
                   state <= 3'b000;
                   next_state =  mG_sR;
              end
                  else 
                   state <= next_state; 
              
    end
    
    always @ (posedge slow_clk) 
    begin
          count <= count + 1 ;
        
        if (count == 5 && sensor && (en1 || en4)) 
            jam_exists <= 1;
            
            
        if (count == 11 && en1 && ~jam_exists) 
        begin
      
          d1 <= 1; d2 <= 0; d3 <= 0; d4 <= 0;  d5 <= 0; d6 <= 0;
          count <= 0;
          
        end
        
        else if (count == 8 && (en1 || en4) && jam_exists)
        begin
          d1 <= 1; d2 <= 0; d3 <= 0; d4 <= 1; d5 <= 0; d6 <= 0;
          count <= 0;
          jam_exists <=0;
          
        end
        
        else if (count == 1 && en2)
        begin
        
          d1 <= 0;  d2 <= 1; d3 <= 0; d4 <= 0; d5 <= 0; d6 <= 0;
          count <= 0;
          
        end
        
        else if (count == 5 && en4 && ~ jam_exists) 
        begin
        
          d1<=0;  d2<=0; d3<=0; d4<=1; d5<=0; d6<=0;
          count <= 0;
        end
        
        else if (count == 2 && en3 )
        begin
        
          d1<=0;  d2<=0; d3<=1; d4<=0; d5<=0; d6<=0;
          count <= 0;
       
        end
        
        else if (count == 1 && en5 )
        begin
        
          d1<=0;  d2<=0; d3<=0; d4<=0; d5<=1; d6<=0;
          count <= 0;
         
        end
        
        else if (count == 2 && en6 )
        begin
        
          d1<=0; d2<=0; d3<=0; d4<=0;  d5<=0; d6<=1;
          count <= 0;
          
          
        end 
        
        else 
        begin
          d1<=0;  d2<=0; d3<=0; d4<=0;  d5<=0; d6<=0;
           
        end
        
    end


endmodule
//Clock_Divider Module 

module Clock_Divider#(parameter n = 50000000)(input clk, input reset, output reg clk_out);
    
    reg[31:0] counter;
    always @ (posedge (clk), posedge (reset)) 
    begin 
        
        if(reset == 1)begin
            counter <= 32'd0;
        end
        else begin
            if(counter==n-1)
               begin counter<=32'd0; end
            else
            begin counter <= counter+1; end
        end
        
    end
    
always @ (posedge clk,posedge reset) 
    begin
        if(reset == 1'b1)begin
            clk_out=1'b0;
        end
        else begin
            if(counter==n-1)
                clk_out <= ~clk_out;
            else clk_out <= clk_out;
        end
    end
    
endmodule







//Debouncer Module 

module debouncer (clockIn,reset,out,in);
    input in,clockIn,reset;
    output out;
    reg ff1,ff2,ff3;
    
    
    always @(posedge clockIn or posedge reset)  begin
     if(reset==1'b1) begin
         ff1 <= 1'b0;
         ff2 <= 1'b0; 
         ff3 <= 1'b0; 
     end
     else begin
         ff1 <= in;
         ff2 <= ff1;
         ff3 <= ff2;
     end
    end
    
    assign out = ff1 & ff2 & ff3;

endmodule

















// Constraint file

// set_property PACKAGE_PIN W5 [get_ports clk]
// set_property IOSTANDARD LVCMOS33 [get_ports clk] 

// set_property PACKAGE_PIN R2 [get_ports sensor]
// set_property IOSTANDARD LVCMOS33 [get_ports sensor] 

// set_property PACKAGE_PIN W19 [get_ports walk_request1]
// set_property IOSTANDARD LVCMOS33 [get_ports walk_request1] 
// set_property PACKAGE_PIN T17 [get_ports walk_request2]
// set_property IOSTANDARD LVCMOS33 [get_ports walk_request2]
// set_property PACKAGE_PIN T18 [get_ports walk_request3]
// set_property IOSTANDARD LVCMOS33 [get_ports walk_request3]
// set_property PACKAGE_PIN U17 [get_ports walk_request4]
// set_property IOSTANDARD LVCMOS33 [get_ports walk_request4]


// set_property PACKAGE_PIN V17 [get_ports rst]
// set_property IOSTANDARD LVCMOS33 [get_ports rst] 

// set_property PACKAGE_PIN L1 [get_ports main_G]
// set_property IOSTANDARD LVCMOS33 [get_ports main_G]
// set_property PACKAGE_PIN P1 [get_ports main_Y]
// set_property IOSTANDARD LVCMOS33 [get_ports main_Y] 
// set_property PACKAGE_PIN N3 [get_ports main_R]
// set_property IOSTANDARD LVCMOS33 [get_ports main_R] 
// set_property PACKAGE_PIN U19 [get_ports side_G]
// set_property IOSTANDARD LVCMOS33 [get_ports side_G] 
// set_property PACKAGE_PIN E19 [get_ports side_Y]
// set_property IOSTANDARD LVCMOS33 [get_ports side_Y]
// set_property PACKAGE_PIN U16 [get_ports side_R]
// set_property IOSTANDARD LVCMOS33 [get_ports side_R] 

// set_property PACKAGE_PIN V14 [get_ports walk_signal]
// set_property IOSTANDARD LVCMOS33 [get_ports walk_signal] 

// set_property PACKAGE_PIN U3 [get_ports jam_exists]
// set_property IOSTANDARD LVCMOS33 [get_ports jam_exists] 
