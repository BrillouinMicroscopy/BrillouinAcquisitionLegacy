function acquisition = Acquisition(model, view)

    %% callbacks Acquisition
    set(view.acquisition.start, 'Callback', {@startAcquisition, model, view});
    set(view.acquisition.stop, 'Callback', {@stopAcquisition, model});
        
    acquisition = struct( ...
    ); 
end

function startAcquisition(~, ~, model, view)
    model.settings.acquisition = 1;
    acquire(model, view);
    model.settings.acquisition = 0;
end

function stopAcquisition(~, ~, model)
    model.settings.acquisition = 0;
end