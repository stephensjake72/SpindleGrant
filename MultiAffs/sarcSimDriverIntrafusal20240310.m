function [hsB,dataB,hsC,dataC] = sarcSimDriverIntrafusal20240310(t,delta_f_activated,delta_cdl,sarcB,sarcC)
time_step = t(2)-t(1);

% Make a half-sarcomere
hsB = halfSarcWithCoopBag(sarcB.f,sarcB.g);
hsB.power_stroke = sarcB.power_stroke;
% hsB.hs_length = sarcB.hs_length;
hsB.hsl_slack = sarcB.hsl_slack;
hsB.k_passive = sarcB.k_passive;
hsB.compliance_factor = sarcB.compliance_factor;

hsC = halfSarcWithCoopChain(sarcC.f,sarcC.g);
hsC.power_stroke = sarcC.power_stroke;
% hsC.hs_length = sarcC.hs_length;
hsC.hsl_slack = sarcC.hsl_slack;
hsC.k_passive = sarcC.k_passive;
hsC.compliance_factor = sarcC.compliance_factor;

% Loop through the time-steps
for i=1:numel(t)
hsB.pCa_perStep = sarcB.pCa(i);
hsC.pCa_perStep = sarcC.pCa(i);
if i==1
    hsB.hs_length = sarcB.hs_length;
    hsC.hs_length = sarcC.hs_length;
end

%         if hsB.hs_force <= 1e3
%             sarcB.checkSlack = 1;
%         elseif hsC.hs_force <= 1e3
%             sarcC.checkSlack = 1;
%         else
%             sarcB.checkSlack = 0;
%             sarcC.checkSlack = 0;
%         end
        
    if sarcB.checkSlack
        xB = find_hsl_from_force_spindle(hsB,0.0);
        if hsB.cmd_length<xB
            hsB.hs_force = 0;
            slack_modeB = 1;
            adj_lengthB = xB - hsB.hs_length;
            hsB.forwardStep(0.0,adj_lengthB,0,0,0,1);
        else
            slack_modeB = 0;
        end
        if slack_modeB
            %CROSS BRIDGE EVOLUTION TAKES UP SLACK
            % Any cb cycling here must be applied to shortening
            % against zero load.

            % First, we evolve the distribution
            hsB.forwardStep(time_step,0.0,0.0,delta_f_activated(1,i),1,0)

            % Next, we iteratively search for the sarcomere length
            % that would give us zero load
            xB = find_hsl_from_force_spindle(hsB,0);

            % We then compute the new hs length applied to the
            % sarcomere based on whether the command length is now
            % greater than the sarcomere length (back into
            % length-control) or not (still in isotonic mode). The
            % length adjustment is the the calculated new length - the
            % current measurement of hs length.

            new_lengthB = max(xB,hsB.cmd_length);
            adj_lengthB = new_lengthB - hsB.hs_length;

            % Finally, we shift the distribution by the adjusted length
            hsB.forwardStep(time_step,adj_lengthB,delta_cdl(1,i),0,0,1);
        else %length control
            delta_hslB = delta_cdl(1,i);
            hsB.forwardStep(time_step,delta_hslB,delta_cdl(1,i),delta_f_activated(1,i),1,1);
        end
    else %Assume length control
        delta_hslB = delta_cdl(1,i);
        hsB.forwardStep(time_step,delta_hslB,delta_cdl(1,i),delta_f_activated(1,i),1,1);
    end

    if sarcC.checkSlack
        xC = find_hsl_from_force_spindle(hsC,0.0);
        if hsC.cmd_length<xC
            hsC.hs_force = 0;
            slack_modeC = 1;
            adj_lengthC = xC - hsC.hs_length;
            hsC.forwardStep(0.0,adj_lengthC,0,0,0,1);
        else
            slack_modeC = 0;
        end
        if slack_modeC
            %CROSS BRIDGE EVOLUTION TAKES UP SLACK
            % Any cb cycling here must be applied to shortening
            % against zero load.

            % First, we evolve the distribution
            hsC.forwardStep(time_step,0.0,0.0,delta_f_activated(1,i),1,0)

            % Next, we iteratively search for the sarcomere length
            % that would give us zero load
            xC = find_hsl_from_force_spindle(hsC,0);

            % We then compute the new hs length applied to the
            % sarcomere based on whether the command length is now
            % greater than the sarcomere length (back into
            % length-control) or not (still in isotonic mode). The
            % length adjustment is the the calculated new length - the
            % current measurement of hs length.

            new_lengthC = max(xC,hsC.cmd_length);
            adj_lengthC = new_lengthC - hsC.hs_length;

            % Finally, we shift the distribution by the adjusted length
            hsC.forwardStep(time_step,adj_lengthC,delta_cdl(1,i),0,0,1);

        else %length control
            delta_hslS = delta_cdl(1,i);
            hsC.forwardStep(time_step,delta_hslS,delta_cdl(1,i),delta_f_activated(1,i),1,1);
        end
    else %Assume length control
        delta_hslC = delta_cdl(1,i);
        hsC.forwardStep(time_step,delta_hslC,delta_cdl(1,i),delta_f_activated(1,i),1,1);
    end
    if mod(i,100)==0, disp(['done with t' num2str(i)]);end


    % Store data

    dataB(1).f_activated(i) = hsB.f_activated;
    if sarcB.isActin==1
        dataB(1).f_bound(i) = sum(hsB.bin_pops);
    else
        dataB(1).f_bound(i) = hsB.f_bound;
    end
    dataB(1).t(i) = t(i);
    dataB(1).f_overlap(i) = hsB.f_overlap;
    dataB(1).cb_force(i) = hsB.cb_force;
    dataB(1).passive_force(i) = hsB.passive_force;
    dataB(1).hs_force(i) = hsB.hs_force;
    dataB(1).hs_length(i) = hsB.hs_length;
    dataB(1).cmd_length(i) = hsB.cmd_length;
    dataB(1).bin_pops(:,i) = hsB.bin_pops;
    dataB(1).no_detached(i) = hsB.no_detached;

    dataC(1).f_activated(i) = hsC.f_activated;
    if sarcC.isActin==1
        dataC(1).f_bound(i) = sum(hsC.bin_pops);
    else
        dataC(1).f_bound(i) = hsC.f_bound;
    end
    dataC.t(i) = t(i);
    dataC(1).f_overlap(i) = hsC.f_overlap;
    dataC(1).cb_force(i) = hsC.cb_force;
    dataC(1).passive_force(i) = hsC.passive_force;
    dataC(1).hs_force(i) = hsC.hs_force;
    dataC(1).hs_length(i) = hsC.hs_length;
    dataC(1).cmd_length(i) = hsC.cmd_length;
    dataC(1).bin_pops(:,i) = hsC.bin_pops;
    dataC(1).no_detached(i) = hsC.no_detached;
end

end