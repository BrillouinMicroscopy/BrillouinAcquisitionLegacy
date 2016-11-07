function acquisition = Acquisition(model, view)

    %% callbacks Acquisition
    set(view.acquisition.start, 'Callback', {@startAcquisition, model, view});
    set(view.acquisition.stop, 'Callback', {@stopAcquisition, model});
        
    acquisition = struct( ...
    ); 
end

function startAcquisition(~, ~, model, view)
    if isa(model.andor,'Utils.AndorControl.AndorControl') && isvalid(model.andor)
        model.settings.acquisition = 1;
        acquire(model, view);
        model.settings.acquisition = 0;
    else
        disp('Please connect to the camera first.');
    end
end

function stopAcquisition(~, ~, model)
    model.settings.acquisition = 0;
end