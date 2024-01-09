%%% Matlab E4350B/E4351 Solar Array Simulator Class
% Uses Prologix gpib usb adapter



classdef e4351_driver < handle
    properties
        serial_driver
        serial_port_name
        gpib_address
    end

    methods
        function obj = e4351_driver(serial_port,gpib_addr)
            obj.gpib_address = gpib_addr;
            obj.serial_port_name = "";
            if (isa(class(serial_port),'string'))
                obj.serial_port_name = serial_port;
                obj.serial_driver = serial(obj.serial_port_name);
                obj.serial_driver.Terminator = 'CR/LF';
                obj.serial_driver.Timeout = .5;
                fopen(obj.serial_driver);
                fprintf(obj.serial_driver, '++mode 1');
                fprintf(obj.serial_driver,'++auto 1');
            else
                obj.serial_driver = serial_port;
            end
        end

        function idn_str = identify_signal_analyzer(obj)
            fprintf(obj.serial_driver,'++addr %d',obj.gpib_address);
            fprintf('*IDN?');
            idn_str = fread(obj.serial_driver,100);
            disp(idn_str);
        end

        function set_to_sas_mode(obj)
            fprintf(obj.serial_driver,'++addr %d',obj.gpib_address);
            fprintf(obj.serial_driver,':CURR:MODE SAS');
            fprintf(obj.serial_driver,':CURR:MODE?');
            curr_mode = fread(obj,50);
            disp(curr_mode)
        end

        function curr_level = get_current_current(obj)
            fprintf(obj.serial_driver,'++addr %d',obj.gpib_address);
            fprintf(obj.serial_driver,":SOUR:CURR:LEV?");
            curr_level = fread(obj.serial_driver,50);
            disp(curr_level);
        end

        function volt_level = get_current_voltage(obj)
            fprintf(obj.serial_driver,'++addr %d',obj.gpib_address);
            fprintf(obj.serial_driver,":SOUR:VOLT:LEV?");
            volt_level = fread(obj.serial_driver,50);
            disp(volt_level);
        end

        function isc_level = get_current_isc(obj)
            fprintf(obj.serial_driver,'++addr %d',obj.gpib_address);
            fprintf(obj.serial_driver,":SOUR:CURR:SAS:ISC?");
            isc_level = fread(obj.serial_driver,50);
            disp(isc_level);
        end

        function voc_level = get_current_voc(obj)
            fprintf(obj.serial_driver,'++addr %d',obj.gpib_address);
            fprintf(obj.serial_driver,":SOUR:VOLT:SAS:VOC?");
            voc_level = fread(obj.serial_driver,50);
            disp(voc_level);
        end

        function imp_level = get_current_imp(obj)
            fprintf(obj.serial_driver,'++addr %d',obj.gpib_address);
            fprintf(obj.serial_driver,":SOUR:CURR:SAS:IMP?");
            imp_level = fread(obj.serial_driver,50);
            disp(imp_level);
        end

        function vmp_level = get_current_vmp(obj)
            fprintf(obj.serial_driver,":SOUR:VOLT:SAS:VMP?");
            vmp_level = fread(obj.serial_driver,50);
            disp(vmp_level);
        end

        function set_sas_values(obj,isc,imp,voc,vmp)
            fprintf(obj.serial_driver,'++addr %d',obj.gpib_address);
            command = sprintf(":CURR:SAS:ISC %.3f;IMP %.3f;:VOLT:SAS:VOC %.3f;VMP %.3f",isc,imp,voc,vmp);
            fprintf(obj.serial_driver,command);

        end

        function reset_psu(obj)
            fprintf(obj.serial_driver,'++addr %d',obj.gpib_address);
            fprintf(obj.serial_driver,'*RST');
        end

        function close_connection(obj)
            fclose(obj.serial_driver);
        end


    end

end