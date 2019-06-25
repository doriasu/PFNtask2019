`timescale 1ps/1ps
module COUNTER_TB;
    reg OSC50M;
    reg CLKENB;
    reg RST;
    wire[7:0]inc;
    wire[7:0]dec;
    i_counter_top COUNTER(
        .CLK (OSC50M),
        .RST (RST),
        .CE(CLKENB),
        .inc (inc[7:0]),
        .dec(dec[7:0])
    );
    

    //clockgenerator
    parameter OSC50M_PERIOD=10;//ps
    initial begin
        OSC50M=1'b0; 
    end
    always #(OSC50M_PERIOD/2)begin
        OSC50M<=~OSC50M;
    end
    reg[1:0]clkEnbCntr;
    initial begin
        CLKENB=1'b0;
        clkEnbCntr=2'b0;
    end
    always@(posedge OSC50M)begin
        clkEnbCntr[1:0]<=clkEnbCntr[1:0]+2'd1;
        CLKENB<=(clkEnbCntr[1:0]==2'd1);
    end
    //reset_generator
    initial begin
        RST=1;
        repeat(20)@(negedge OSC50M);
        RST=0;
    end
    //test vector
    initial begin
        @(negedge OSC50M);
        while (RST) @(negedge OSC50M);
        repeat(10000)@(negedge OSC50M);
        $finish;
    end
    initial begin
    $dumpfile("and2test.vcd");
    $dumpvars(0,COUNTER_TB);
    end
endmodule

module i_counter_top(
    input CLK,
    input RST,
    input CE,
    output[7:0]inc,
    output[7:0]dec

);
wire[7:0]inc;
wire[7:0]dec;
wire CLK;
wire RST;
wire CE;
wire cnton;
wire [7:0]XX;
reg incRST;
reg decRST;
reg [7:0]Q;
reg start;
reg iji;
reg resetdec;
initial begin
    incRST<=1;
    decRST<=1;
    resetdec<=0;
end
i_inc_counter INC(
    .CLK(CLK),
    .RST(incRST),
    .CE(CE),
    .Q(inc),
    .iji(iji)

);
i_dec_counter DEC(
    .CLK(CLK),
    .RST(decRST),
    .CE(CE),
    .Q(dec),
    .XX(XX),
    .start(start)

);
always@(posedge CLK)begin
    if(XX==1)begin
        incRST<=1;
        iji<=1;
        start<=0;
        decRST<=1;
        resetdec<=1;
    end
    else if(inc[7:0]==1)begin
        resetdec<=0;
    end
    else if(inc[7:0]==0&&dec[7:0]==0)begin
        incRST<=0;
        iji<=1;
    end else if(inc[7:0]==8'd6&&dec[7:0]==0&&resetdec==0) begin
        iji<=0;
        decRST<=0;
        start<=1;
        

    end else if(dec[7:0]==8'd0&&iji==0) begin
        incRST<=1;
        decRST<=1;
    end else begin
        incRST<=0;
        start<=0;
        iji<=1;
    end
end
endmodule

module i_inc_counter(
    input CLK,
    input RST,
    input CE,
    input iji,
    output[7:0]Q

);
reg[7:0]Q;
always@(posedge CLK)begin
    if(RST)begin
        Q[7:0]<=8'd0;
    end else begin
        if(CE&&iji)begin
            if(Q[7:0]<6)begin
            Q[7:0]<=Q[7:0]+8'd1;
            end
        end
    end
end
endmodule

module i_dec_counter(
    input CLK,
    input RST,
    input CE,
    output[7:0]Q,
    output[7:0]XX,
    input start
);
reg[7:0]Q;
wire start;
reg x;
reg[7:0]XX=0;


always@(posedge CLK)begin
    XX<=0;

    if(RST)begin
        Q[7:0]<=8'd0;
        x<=0;

    end else begin
        if(CE&&start&&x==0)begin
            Q[7:0]<=8'd3;
            x<=1;
            
        end
        else if(CE)begin
            if(Q[7:0]>0)begin
                Q[7:0]<=Q[7:0]-8'd1;
                
            end
            if(Q[7:0]==0)begin
                    XX<=8'd1;
                end
        end
    end
end
endmodule