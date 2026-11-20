# traffic_light example for svga_imitator
This is an example of an FSM, which controls a traffic light.
The controlled traffic light is drawn on the VGA or SVGA interface. It can be viewed using the VGA output of an FPGA board (tested on de10_lite) or tested using svga_imitator and Vivado.

Tests for the functionality of both the FSM and the VGA/SVGA output are implemented as well.

## 1. Project structure
The example integrates with basics-graphics-music project, especially for the synthesis. BGM scripts are functional, except for 02_simulate_rtl.bash, as the simulation and the tests are done using Vivado and svga_imitator.

You can find the lab_top.sv as well as the other modules in the root folder of the example.
Testbenches and their dependencies are located in ./tb

Scripts to run a simulation or a test using Vivado are located in ./run_sim_vivado

First it is necessary to follow instructions from ./run_sim_vivado/env_user.sh.in, then execute "source ./run_sim_vivado/env.sh" to initialise Vivado.

Now you can run the included tests (./run_sim_vivado/sim_01 and ./run_sim_vivado/sim_02) by executing
compile.sh
elaborate.sh
c_run_0.sh or c_run_1_sh or g_run.sh
in the directory of required simulation

## 2. Modules
lab_top.sv - main module of this example, contains logic for drawing the traffic light on screen
ellipse.sv - used to determine if a point (pixel) belongs to a non-filled ellipse.
complex_filled_ellipse.sv - used to determine if a point (pixel) belongs to a filled ellipse with the form of traffic light's lamp.
line.sv - used to determine if a point (pixel) belongs to a straight line
FSM_1.sv - the Mealy machine which outputs the states of red, yellow and green lamps
bind_FSM_1.sv - bind for the FSM, used to test coverage.
tick_05s_generator.sv - outputs a slower clock frequency for the FSM's timer. IS_SIMULATION parameter controls the tick's length. If IS_SIMULATION=1, a single tick is around 0.5µs, to reduce the simulation time. If IS_SIMULATION=0 (synthesis value) a single tick is 0.5s. For reference red light lasts 20 ticks.


## 3. Tests
In sim_01 there is only 1 test
It outputs 8 images to svga_imitator to test the traffic lights VGA output. Those 8 pictures are all possible combinations of 3 lights. This mode requires IS_SIMULATION = 2. FSM is disabled as it isn't tested. Requires svga_imitator running parallel to Vivado.

In sim_02:
Test 1 - checks, if the sequence of the FSM's outputs and therefore turned on lights is correct
Test 2 - has a similar purpose, but is implemented using covergroups and transition bins. 
VGA output is disabled, as it isn't tested.




