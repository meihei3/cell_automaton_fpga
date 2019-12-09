//
// Configuration     VGA(60Hz)
// Resolution(HxV)   640x480
//
// ---------------------------------------------------------------------------------
// |                  | Horizontal Timing Spec (us) | Vertical Timing Spec (lines) |
// |------------------|-----------------------------|------------------------------|
// | Sync             |                         3.8 |                            2 |
// | Black porch      |                         1.9 |                           33 |
// | Display interval |                        25.4 |                          480 |
// | Front porch      |                         0.6 |                           10 |
// |------------------|-----------------------------|------------------------------|
// | Pixel clock(MHz) |                          25 |                           25 |
// ---------------------------------------------------------------------------------
//

module vga_controller(vga_clk, clrn, r, g, b, hsync_out, vsync_out, vga_sync_n, vga_blank_n, row_addr, col_addr);

parameter H_COUNTER_MAX = 10'd96 + 10'd48 + 10'd640 + 10'd16 - 10'd1;
parameter H_SYNC_TIME   = 10'd96                             - 10'd1;
parameter H_READ_MIN    = 10'd96 + 10'd48                    - 10'd2;
parameter H_READ_MAX    = 10'd96 + 10'd48 + 10'd640          - 10'd1;
parameter H_ADDR_OFFSET = 10'd96 + 10'd48                           ;
parameter V_COUNTER_MAX = 10'd2  + 10'd33 + 10'd480 + 10'd10 - 10'd1;
parameter V_SYNC_TIME   = 10'd2                              - 10'd1;
parameter V_READ_MIN    = 10'd2  + 10'd33                    - 10'd1;
parameter V_READ_MAX    = 10'd2  + 10'd33 + 10'd480          - 10'd1;
parameter V_ADDR_OFFSET = 10'd2  + 10'd33                           ;

input            vga_clk, clrn;

output reg [7:0] r, g, b;
output reg       hsync_out, vsync_out;
output reg       vga_sync_n, vga_blank_n;

output reg [8:0] row_addr;
output reg [9:0] col_addr;


// hsync
reg  [9:0] h_count;
wire       hsync = (h_count > H_SYNC_TIME);

always @(posedge vga_clk or negedge clrn) begin
    if (!clrn) begin
        h_count <= 10'd0;
    end else if (h_count == H_COUNTER_MAX) begin
        h_count <= 10'd0;
    end else begin
        h_count <= h_count + 10'd1;
    end
end


// vsync
reg  [9:0] v_count;
wire       vsync = (v_count > V_SYNC_TIME);

always @(posedge vga_clk or negedge clrn) begin
    if (!clrn) begin
        v_count <= 10'd0;
    end else if (h_count == H_COUNTER_MAX) begin
        if (v_count == V_COUNTER_MAX) begin
            v_count <= 10'd0;
        end else begin
            v_count <= v_count + 10'd1;
        end
    end
end


// check display able
reg  rdn;
wire read = ((H_READ_MIN < h_count) && (h_count < H_READ_MAX)) && ((V_READ_MIN < v_count) && (v_count < V_READ_MAX));


// set ram addr
wire [8:0] row = v_count - V_ADDR_OFFSET;
wire [9:0] col = h_count - H_ADDR_OFFSET;


// output
always @(posedge vga_clk) begin
    rdn       <= ~read;
    r         <= 8'b0000_0000;
    g         <= 8'b0000_0000;
    b         <= rdn ? 8'b0 : 8'b1111_1111;
    hsync_out <= hsync;
    vsync_out <= vsync;
    row_addr  <= row;
    col_addr  <= col;
end

initial begin
    vga_sync_n = 0;
    vga_blank_n = 1;
end

endmodule // vga_controller