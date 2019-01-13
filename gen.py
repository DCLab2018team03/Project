import random


for i in range(32):
    s = '''
@(negedge clk);
pitch_sdram_finished = 1;
pitch_readdata = 32'h{};
@(negedge clk);
pitch_sdram_finished = 0;'''.format(hex(random.randint(0,0xffffffff))[2:])
    print(s,end='')