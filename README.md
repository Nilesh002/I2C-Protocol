# I2C-Protocol 


## Description:
This repository contains Verilog code for an I2C (Inter-Integrated Circuit) IP controller designed for use in Xilinx Vivado. The I2C controller facilitates communication between various devices in an embedded system using the I2C protocol.

## Contents:
1. **i2c_ip.v**: Verilog module for the I2C IP controller, responsible for managing communication between the processor and the I2C bus.
2. **i2c_master.v**: Verilog module for the I2C master, which handles the transmission and reception of data on the I2C bus.
3. **i2c_controller.v**: Verilog module for the I2C controller, which interfaces between the processor and the I2C master.



## Repository Structure:


```
RTL
│
├── I2C_IP.v
├── I2C_Master.v
├── I2C_Controller.v
└── README.md
```


## Usage Instructions:
1. Clone the repository to your local machine.
2. Open the project in Xilinx Vivado.
3. Modify the code as needed for your specific application.
4. Simulate or synthesize the design in Vivado.
5. Program your FPGA with the generated bitstream to implement the I2C controller.




## Simulation Image:
![I2C Simulation](https://github.com/Nilesh002/I2C-Protocol/assets/105161049/c178848e-21ad-4697-9e77-4db739d703de)


## Synthesized Schematic Image:
![I2C_Sythesis](https://github.com/Nilesh002/I2C-Protocol/assets/105161049/acf9509c-93cc-488a-953c-34a481f1cf1d)






## Additional Information about I2C:
### What is I2C?
I2C (Inter-Integrated Circuit) is a synchronous, multi-master, multi-slave, packet-switched, single-ended, serial communication bus invented by Philips Semiconductor (now NXP Semiconductors).

### How does I2C work?
I2C uses two bidirectional lines: SDA (data line) and SCL (clock line). Multiple slave devices can be connected to the same bus, and each device has a unique address. Communication is initiated by a master device, which generates clock pulses on the SCL line while sending or receiving data on the SDA line.

### Key features of I2C:
- Simple hardware interface
- Support for multiple devices on the same bus
- Bidirectional communication
- Synchronous data transfer
- Low-speed communication (typically up to 100 kHz for standard mode and 5 MHz for Ultra-fast mode)

### Applications of I2C:
I2C is commonly used in various embedded systems for communication between microcontrollers and peripheral devices such as sensors, EEPROMs, LCD displays, and more.

### Why I2C is needed?
I2C provides a convenient and standardized method for inter-device communication in embedded systems. It simplifies hardware design, reduces wiring complexity, and allows multiple devices to communicate over the same bus, thereby saving I/O pins on the microcontroller.




