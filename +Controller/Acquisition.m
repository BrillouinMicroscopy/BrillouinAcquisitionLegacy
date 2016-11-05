function acquisition = Acquisition(model, view)

    %% callbacks ROI panel
    set(view.acquisition.start, 'Callback', {@startAcquisition, model});
        
    acquisition = struct( ...
    ); 
end

function startAcquisition(~, ~, model)
    acquire(model);
end