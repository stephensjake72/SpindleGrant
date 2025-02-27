classdef halfSarcWithCoopExtrafusal_3state < handle
    
    properties
        % These properties can be accessed from the driver script
        
        % INITIAL STATE PARAMETERS %
        cmd_length = 1300;
        hs_length = 1300;   % the initial length of the half-sarcomere in nm
        hs_force;           % the stress (in N m^(-2)) in the half-sarcomere
        f_overlap;
        f_bound;
        f_activated = 0.0;
        cb_force;
        passive_force;
        Ca;
        pCa_perStep;
        tendon_stiffness;

        % DISTRIBUTION BIN PARAMETERS %
        bin_min = -20;      % min x value for myosin distributions in nm
        bin_max = 20;       % max x value for myosin distributions in nm
        bin_width = 0.5;    % width of bins for myosin distributions in nm
        x_bins;             % array of x_bin values
        no_of_x_bins;       % no of x_bins
        
        % INDIVIDUAL CROSSBRIDGE PARAMETERS %
        k_cb = 0.001;       % Cross-bridge stiffness in N m^-1
        power_stroke = 2.5;   % Cross-bridge power-stroke in nm
        
        % PARAMETERS RELATED TO FORWARD AND REVERSE RATES %
        f_parameters = 20;
        g_parameters = 20;
                            

        thick_filament_length = 815;
                            % length of thick filaments in nm=
        thin_filament_length = 1120;
                            % length of thin filaments in nm
        bare_zone_length = 80;
                            % length of thick filament bare zone in nm
        k_falloff = 0.002;  % defines how f_overlap falls hs_length shortens
                            % below optimal
                            
        f;                  % forward rates
        g;                  % reverse rates
        srx_f;
        srx_g;
        
        bin_pops;           % number of heads bound in each bin
        no_detached;        % number of heads not attached to a binding site
        no_attached;
        no_actin_off;
        no_on_unbound;
        no_bound;
        y
        
        max_rate = 5000;    % clip f or g values above this value
        
        compliance_factor = 0.50;
                            % proportion of delta_hsl that the
                            % cb distribution is moved
                            
        cb_number_density = 6.9e16;
                            % number of cbs in a half-sarcomere with a
                            % cross-sectional area of 1 m^2
                            
        hsl_slack = 850;   % slack length of half-sarcomere in nm
        k_passive = 0; %5 for non FL and FV trials
                            % passive stiffness of half-sarcomere in
                            % N m^-2 nm^-1

    end
    
    methods
        
        % BUILD halfSarcBag OBJECT %
        function obj = halfSarcWithCoopExtrafusal_3state(varargin)
            
            % Set up x_bins
            obj.x_bins = obj.bin_min:obj.bin_width:obj.bin_max;
            obj.no_of_x_bins = numel(obj.x_bins);

            
            % Set up rates
            obj.srx_f = 6 * ...
                (8 + 5e-4 * max([0 obj.cb_force]));
            obj.srx_f = min([obj.srx_f obj.max_rate]);

            obj.srx_g = min([obj.max_rate 100]);

% %             % Set up rates
% %             %%% D --> A rate (symmetric) %%%
% %             obj.f = zeros(size(obj.x_bins)); %Preallocate
% %             obj.f = obj.f_parameters(1) * ...
% %                 exp(-obj.k_cb*10*((obj.x_bins).^2)/(1e18*1.381e-23*288));
% %             
% %             %%% A --> D rate (asymmetric) %%%
% %             obj.g = zeros(size(obj.x_bins)); %Preallocate
% % %             obj.g = obj.g_parameters(1) + ...
% % %                  (0.1*((obj.x_bins+obj.power_stroke).^4));
% %             obj.g(obj.x_bins<-5) = obj.g_parameters(1) + ...
% %                  abs(0.2*((obj.x_bins(obj.x_bins<-5)+5).^3));
% %             obj.g(obj.x_bins>=-5) = obj.g_parameters(1) + ...
% %                  0.2*((obj.x_bins(obj.x_bins>=-5)+5).^3);
% %             obj.g = obj.g + 0.5;

            obj.f = zeros(size(obj.x_bins)); %Preallocate
            obj.f = 1200 - 65*((obj.x_bins-2).^2);
            obj.f(obj.f<0) = 0;
            obj.f(obj.f>obj.max_rate)=obj.max_rate;


            obj.g = zeros(size(obj.x_bins)); %Preallocate
            obj.g(obj.x_bins<0) = 1000*(obj.x_bins(obj.x_bins<0)-0).^2;
%             obj.g(obj.x_bins>=0) = 10;
            obj.g(obj.x_bins>=0) = (5*(obj.x_bins(obj.x_bins>=0)-0).^2)+10;
            obj.g(obj.g>obj.max_rate)=obj.max_rate;

%             r1 = obj.parameters.k_1 * ...
%         (1 + obj.parameters.k_force * max([0 obj.int_total_force]));
% r1 = min([r1 obj.parameters.max_rate]);
% 
% r2 = min([obj.parameters.max_rate obj.parameters.k_2]);
% 
% r3 = obj.parameters.k_3 * ...
%             exp(-obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
%                 (2 * 1e18 * obj.parameters.k_boltzmann * ...
%                     obj.parameters.temperature));
% r3(r3>obj.parameters.max_rate)=obj.parameters.max_rate;
% 
% r4 = obj.parameters.k_4_0 + ...
%                 (obj.parameters.k_4_1 * ...
%                     ((obj.myofilaments.x + 0 * obj.parameters.x_ps).^4));
% r4(r4>obj.parameters.max_rate)=obj.parameters.max_rate;

            
            % Limit max values
            obj.f(obj.f>obj.max_rate) = obj.max_rate;
            obj.g(obj.g>obj.max_rate) = obj.max_rate;
            
            % Initialize bins
            obj.bin_pops = zeros(obj.no_of_x_bins,1);
            obj.y = [1 ; 0 ; obj.bin_pops; 1; 0];
            
        end
        
        % Other methods
        function update_filamentOverlap(obj)
            
            x_no_overlap = obj.hs_length - obj.thick_filament_length; %Length of thin filament w/0 overlapping thick filament
            x_overlap = obj.thin_filament_length - x_no_overlap; %
            max_x_overlap = obj.thick_filament_length -  ...
                obj.bare_zone_length; %Region of thick filament containing myosin heads
            
            if (x_overlap<0) %This is impossible in a sarcomere
                obj.f_overlap=0;
            end
            
            if ((x_overlap>0)&&(x_overlap<=max_x_overlap)) %Operating range of half sarcomere
                obj.f_overlap = x_overlap/max_x_overlap;
            end
            
            if (x_overlap>max_x_overlap) %This is impossible in a sarcomere
                obj.f_overlap=1;
            end
            protrusion = obj.thin_filament_length - ...
                (obj.hs_length + obj.bare_zone_length);
            
            if (protrusion > 0)
                x_overlap = (max_x_overlap - protrusion);
                obj.f_overlap = x_overlap / max_x_overlap;
            end
                       
        end
        
        
        function update_fracBound(obj)
            obj.f_bound = sum(obj.bin_pops);
        end
        
        function update_thinFilament(obj)
                        
             obj.f_activated = obj.f_activated;
            
        end
        
        
        
        
        function evolve_cbDist(obj,time_step)
            
            % Construct a vector y where
            % y(1) is the number of cbs in the detached state
            % y(2 ... no_of_x_bins+1) is the number of cbs in bins 1 to no_of_x_bins
            
            y = obj.y;
            
            % Evolve the system
            [~,y_new] = ode23(@derivs,time_step*[0 1],y,[]);
            
            % Update the bound cross-bridges
            obj.bin_pops = y_new(end,3:end-2)';
            obj.no_detached = y_new(end,1);
            obj.y=y_new(end,:);
            
            function dy = derivs(~,y)
            % Update the bound cross-bridges
            f_myosin_srx = y(1);
            f_myosin_detached = y(2); 
            n_myosin_attached = y(3:end-2);
            f_actin_off = y(end-1);
            f_actin_on_unbound = y(end);
            f_actin_bound = sum(n_myosin_attached);
            
            
                % Calculating fluxes as from MyoSim 2 state (copied pretty
                % much)
                J1 = obj.srx_f * f_myosin_srx;
                J2 = obj.srx_g * f_myosin_detached;
                J3 = obj.f .* obj.bin_width * f_myosin_detached * (f_actin_on_unbound - f_actin_bound);
                J4 = obj.g .* (n_myosin_attached');
                x_no_overlap = obj.hs_length - obj.thick_filament_length;
                if ((obj.thin_filament_length - x_no_overlap)>0)
                    J_on = 80000000 * (10^(-obj.pCa_perStep)) * (obj.f_overlap - f_actin_on_unbound) * ...
                        (1 + 5 * (f_actin_on_unbound/obj.f_overlap));
                    J_off = 200 * (f_actin_on_unbound - f_actin_bound) * ...
                        (1 + 5 * ((obj.f_overlap - f_actin_on_unbound)/obj.f_overlap));
                else
                    J_on = 0;
                    J_off = 200 * (f_actin_on_unbound - f_actin_bound);
                end

                dy=zeros(length(y),1);
                % Calculate the derivs
                dy(1) = -J1 + J2;
                dy(2) = (J1 + sum(J4)) - (J2 + sum(J3));
                for i=1:obj.no_of_x_bins
                    dy(2+i) = J3(i) - J4(i);
                end
                dy(end-1) = -J_on + J_off;
                dy(end) = J_on - J_off;
                
            end
        end
        
        
        function shift_cbDist(obj,delta_x)
            % Adjust for filament compliance
            delta_x = delta_x * obj.compliance_factor;
            % Shift populations by interpolation
            interp_positions = obj.x_bins - delta_x;
            cbs_bound_before = sum(obj.y(3:end-2));
            obj.y(3:end-2) = interp1(obj.x_bins,obj.y(3:end-2),interp_positions, ...
                'linear',0)';
            
            % Try to manage cbs ripped off filaments
            cbs_lost = cbs_bound_before - sum(obj.y(3:end-2));
            if (cbs_lost > 0)
                obj.y(1) = obj.y(1) + cbs_lost;
            end
    
        end
        

        function calcForces(obj,delta_hsl)
            obj.cb_force = obj.cb_number_density * obj.k_cb * 1e-9 * ...
                sum((obj.x_bins + obj.power_stroke) .* (obj.y(3:end-2)));
            obj.passive_force = obj.k_passive * (obj.hs_length - obj.hsl_slack);
            obj.hs_force = obj.cb_force + obj.passive_force;
        end

        
        
        function forwardStep(obj,time_step,delta_hsl,delta_cdl,delta_f_activated,evolve,shift)
            %This function uses the methods for updating the half-sarcomere
            %every time step
                        
            obj.cmd_length = obj.cmd_length + delta_cdl;
            obj.hs_length = obj.hs_length + delta_hsl;
            
%             obj.Ca = obj.Ca + delta_Ca;
            obj.f_activated = obj.f_activated + delta_f_activated;


            
            % Change cb distribution based on cycling kinetics
            if evolve == 1
                                % Calculate the change in f_activated
                obj.update_filamentOverlap();
                obj.update_fracBound();
                obj.update_thinFilament();
                obj.evolve_cbDist(time_step);

            end
            
            % Shift cb distribution based on imposed movements
            % Also, perform calculations that are dependent on hs_length
            if shift == 1
                obj.shift_cbDist(delta_hsl);
            end
                            
            % Calculate forces
            obj.calcForces(delta_hsl);
            
        end
        
    end
end      
            
            
            
            
        
        