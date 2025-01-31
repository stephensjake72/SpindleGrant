function [hs,data] = sarcSimDriverExtrafusal20240310(i,time_step,delta_f_activated,delta_cdl,sarcE)

% Make a half-sarcomere
hs = halfSarcWithCoop(sarcE.f,sarcE.g);
hs.Ca = sarcE.pCa_perStep;
hs.power_stroke = sarcE.power_stroke;
hs.hs_length = sarcE.hs_length;
hs.hsl_slack = sarcE.hsl_slack;
hs.k_passive = sarcE.k_passive;
hs.compliance_factor = sarcE.compliance_factor;

% Loop through the time-steps
if sarcE.checkSlack
    %CHECK IF SLACK
    %ADJUST HS LENGTH SO FORCE IS BACK TO 0
    x = find_hsl_from_force(hs,0.0);

    if hs.cmd_length<x
        hs.hs_force = 0;
        slack_mode = 1;
        adj_length = x - hs.hs_length;
        hs.forwardStep(0.0,adj_length,0,0,0,1);
    else
        slack_mode = 0;
    end

    if slack_mode
        %CROSS BRIDGE EVOLUTION TAKES UP SLACK
        % Any cb cycling here must be applied to shortening
        % against zero load.

        % First, we evolve the distribution
        hs.forwardStep(time_step,0.0,0.0,delta_f_activated(1,i),1,0)

        % Next, we iteratively search for the sarcomere length
        % that would give us zero load
        x = find_hsl_from_force(hs,0);

        % We then compute the new hs length applied to the
        % sarcomere based on whether the command length is now
        % greater than the sarcomere length (back into
        % length-control) or not (still in isotonic mode). The
        % length adjustment is the the calculated new length - the
        % current measurement of hs length.

        new_length = max(x,hs.cmd_length);
        adj_length = new_length - hs.hs_length;

        % Finally, we shift the distribution by the adjusted length
        hs.forwardStep(time_step,adj_length,delta_cdl(1,i),0,0,1);
        warning('%iwrong spot; extrafusal assumes slack',hs.Ca)

    else %length control
        delta_hsl = delta_cdl(1,i);
        hs.forwardStep(time_step,delta_hsl,delta_cdl(1,i),delta_f_activated(1,i),1,1);
        warning('%iwrong spot; extrafusal performs slack calcs',hs.Ca)
    end

else %Assume length control
    delta_hsl = delta_cdl(1,i);
    hs.forwardStep(time_step,delta_hsl,delta_cdl(1,i),delta_f_activated(1,i),1,1);
    %             fprintf('%ino slack actin',hs.Ca)
end

if sarcE.checkSlack
    delta_hsl = delta_cdl(1,i);
    hs.forwardStep(time_step,delta_hsl,delta_cdl(1,i),delta_f_activated(1,i),1,1);
end

% Store data
data(1).f_activated(i) = hs.f_activated;
if sarcE.isActin==1
    data(1).f_bound(i) = sum(hs.bin_pops);
else
    data(1).f_bound(i) = hs.f_bound;
end
data(1).f_overlap(i) = hs.f_overlap;
data(1).cb_force(i) = hs.cb_force;

data(1).passive_force(i) = hs.passive_force;
data(1).hs_force(i) = hs.hs_force;
data(1).hs_length(i) = hs.hs_length;
data(1).cmd_length(i) = hs.cmd_length;
data(1).bin_pops(:,i) = hs.bin_pops;
data(1).no_detached(i) = hs.no_detached;

data(1).t = t;

