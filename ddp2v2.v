`timescale 1ns / 1ps


module dd_p2 (
input clk,
input sensor,
input wlk1,
input wlk2,
input wlk3,
input wlk4,
input rst,
output reg main_G,
output reg main_Y,
output reg main_R,
output reg side_G,
output reg side_Y,
output reg side_R,
output reg w_s,
output reg yes_there_is_afucking_jam

);

// color: green = 00, yellow = 01, red = 10

reg en1=0, en2=0, en3=0, en4=0, en5=0, en6 =0;
reg d1=0, d2=0, d3=0, d4=0,  d5=0, d6 =0;


reg [27:0] count=0;

wire clk_slw;

//Clock_Divider cc (clk, rst, clk_slw);




parameter mG_sR = 3'b000, 
mY_sR = 3'b001,
mR_sR1 = 3'b010,
mR_sR2 = 3'b101,
mR_sG = 3'b011,
mR_sY = 3'b100;


reg[2:0] state, next_state;

reg walk =0;


// next state
always @(posedge clk , negedge rst)
begin
if(rst)
 state <= 3'b000;
else 
 state<=next_state; 
end

// FSM
always @(posedge clk)
begin

if (wlk1 || wlk2 || wlk3 ||  wlk4)  walk =1; 
if (walk)  w_s = 1; else w_s = 0;


case(state)

mG_sR: begin

  en1<=1; en2<=0 ;en3<=0; en4<=0; en5<=0; en6 <=0;

  main_G<=1;
  main_Y<=0;
  main_R<=0;
  side_G<=0;
  side_Y<=0;
  side_R<=1;
  
  
   if (d1) next_state= mY_sR; 
   
    
end

mY_sR: begin

  en1<=0; en2<=1 ;en3<=0; en4<=0; en5<=0; en6 <=0;

  main_G<=0;
  main_Y<=1;
  main_R<=0;
  side_G<=0;
  side_Y<=0;
  side_R<=1;
  
  
   if (d2) begin

   if (walk) next_state = mR_sR1;
   else  next_state = mR_sG;
      
   end 

end

mR_sR1: begin

   en1<=0; en2<=0 ;en3<=1; en4<=0; en5<=0; en6 <=0;

  main_G<=0;
  main_Y<=0;
  main_R<=1;
  side_G<=0;
  side_Y<=0;
  side_R<=1;
  
  walk<=0;
  
  if (d3) next_state = mR_sG;

end

mR_sG:begin

en1<=0; en2<=0 ;en3<=0; en4<=1; en5<=0; en6 <=0;

   main_G<=0;
  main_Y<=0;
  main_R<=1;
  side_G<=1;
  side_Y<=0;
  side_R<=0;
  
  
   
   if (d4) next_state = mR_sY;
   


end

mR_sY: begin

en1<=0; en2<=0 ;en3<=0; en4<=0; en5<=1; en6 <=0;


 main_G<=0;
  main_Y<=0;
  main_R<=1;
  side_G<=0;
  side_Y <= 1;
  side_R <=0;
  
   if (d5) begin

      if (walk) next_state = mR_sR2;
      else next_state = mG_sR;
    
   end 
  

end

mR_sR2:begin

en1<=0; en2<=0 ;en3<=0; en4<=0; en5<=0; en6 <=1;

  main_G <= 0;
  main_Y <=0;
  main_R <=1;
  side_G <=0;
  side_Y <= 0;
  side_R <=1;
  
  walk <= 0;
  
 if (d6) next_state = mG_sR;

end

default: begin

en1<=0; en2<=0 ;en3<=0; en4<=0; en5<=0; en6 <=0;
  
next_state =  mG_sR;

end

endcase

end 


always @ (posedge clk) begin

//if (en1 ||en2 ||en3 ||en4|| en5|| en6 )
  count <= count + 1 ;

if (count == 5 && sensor && (en1 || en4)) 
yes_there_is_afucking_jam = 1;



if (count == 11 && en1 && ~ yes_there_is_afucking_jam ) begin
 
  d1=1; d2=0; d3=0; d4=0;  d5=0; d6 =0;
  count <= 0;


end
else if (count == 8 && (en1 || en4) && yes_there_is_afucking_jam ) begin
 
  d1=1; d2=0; d3=0; d4=1; d5=0; d6 =0;
  count <= 0;
  yes_there_is_afucking_jam <=0;

  

end
else if (count == 3 && en2 ) begin

  d1=0;  d2=1; d3=0; d4=0; d5=0; d6 =0;
  count <= 0;
    

 
end
else if (count == 5 && en4 && ~ yes_there_is_afucking_jam ) begin

  d1=0;  d2=0; d3=0; d4=1; d5=0; d6 =0;
  count <= 0;
   

 
end
else if (count == 3 && en3 ) begin

  d1=0;  d2=0; d3=1; d4=0; d5=0; d6 =0;
  count <= 0;
   


end
else if (count == 3 && en5 ) begin

  d1=0;  d2=0; d3=0; d4=0; d5=1; d6 =0;
  count <= 0;
   

 
end
else if (count == 3 && en6 )begin

  d1=0; d2=0; d3=0; d4=0;  d5=0; d6 =1;
  count <= 0;
  

 

end else begin
  d1=0;  d2=0; d3=0; d4=0;  d5=0; d6 =0;
   


end

end


endmodule


// positive edge detector

module pos_edge_det ( input sig,            // Input signal for which positive edge has to be detected
                      input clk,            // Input signal for clock
                      output pe);           // Output signal that gives a pulse when a positive edge occurs
 
    reg   sig_dly;                          // Internal signal to store the delayed version of signal
 
    // This always block ensures that sig_dly is exactly 1 clock behind sig
  always @ (posedge clk) begin
    sig_dly <= sig;
  end
 
    // Combinational logic where sig is AND with delayed, inverted version of sig
    // Assign statement assigns the evaluated expression in the RHS to the internal net pe
  assign pe = sig & ~sig_dly;            
endmodule 
 
 
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
s