function [hsE, mtData] = musTenDriver20240322(t,delta_f_activated,delta_cdl,sarcE)

hsE = halfSarcWithCoopExtrafusal_3state();
hsE.power_stroke = sarcE.power_stroke;
hsE.hsl_slack = sarcE.hsl_slack;
hsE.k_passive = sarcE.k_passive;
hsE.compliance_factor = sarcE.compliance_factor;
hsE.tendon_stiffness=sarcE.tendon_stiffness;


for i = 1:numel(t)
    hsE.pCa_perStep = sarcE.pCa(i);
    
    if sarcE.isTendon==1
        if i > 1
            time_step = t(i) - t(i-1);
        else
            hsE.hs_length = sarcE.hs_length;
            time_step = t(2) - t(1);

            x_new = mtu_balance_forces_for_spindle(hsE);
            x_adj = x_new - hsE.hs_length;
            hsE.forwardStep(0,x_adj,0,0,0,1);

        end


        hsE.forwardStep(time_step,0,0,delta_f_activated(i),1,0)

        x_new = mtu_balance_forces_for_spindle(hsE);
        x_adj = x_new - hsE.hs_length;
        hsE.forwardStep(0,x_adj,delta_cdl(i),0,0,1);
    else
        if i > 1
            time_step = t(i) - t(i-1);
        else
            hsE.hs_length = sarcE.hs_length;
            time_step = t(2) - t(1);
        end
        delta_hsl = delta_cdl(i);
        hsE.forwardStep(time_step,delta_hsl,delta_cdl(i),delta_f_activated(i),1,1);
    end

    
    mtData.t(i) = t(i);

    mtData.f_activated(i) = hsE.f_activated;
    mtData.f_bound(i) = sum(hsE.bin_pops);
    mtData.f_overlap(i) = hsE.f_overlap;
    mtData.cb_force(i) = hsE.cb_force;
    

    mtData.passive_force(i) = hsE.passive_force;
    mtData.hs_force(i) = hsE.hs_force;
    mtData.hs_length(i) = hsE.hs_length;
    mtData.cmd_length(i) = hsE.cmd_length;
    mtData.bin_pops(:,i) = hsE.bin_pops;
    mtData.no_detached(i) = hsE.no_detached;
end

end

