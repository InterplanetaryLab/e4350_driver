serial_port_name = "PORT4";
gpib1 = 1;
gpib2 = 2;
psu1 = e4351_driver(serial_port_name,gpib1);
psu2 = e4351_driver(psu1.serial_driver,gpib2);

psu1.identify_signal_analyzer()
psu2.identify_signal_analyzer()