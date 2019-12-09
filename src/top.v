module top (sys_clk, clrn, r, g, b, hsync, vsync, vga_sync_n, vga_blank_n, vga_clk);

input        sys_clk, clrn;

output [7:0] r, g, b;          // red, green, blue colors, 8-bit for each
output       hsync, vsync;     // horizontal and vertical synchronization

output       vga_sync_n, vga_blank_n;
output       vga_clk;

// sys_clk to vga_clk
reg vga_clk = 1;
always @(negedge sys_clk) begin
    vga_clk <= ~vga_clk;
end

vga_controller vgac (.vga_clk(vga_clk), .clrn(clrn), .r(r), .g(g), .b(b), .hsync_out(hsync), .vsync_out(vsync),
                     .vga_sync_n(vga_sync_n), .vga_blank_n(vga_blank_n));

endmodule