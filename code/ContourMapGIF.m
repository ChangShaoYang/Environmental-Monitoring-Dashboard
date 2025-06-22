% Read CSV file starting from the first row
opts = detectImportOptions('csv_file');
opts.DataLine = 1;
data = readtable('csv_file', opts);

% Define list of even-numbered IDs (ID2, ID4, ..., ID24)
IDs = {'ID2', 'ID4', 'ID6', 'ID8', 'ID10', 'ID12', 'ID14', 'ID16', 'ID18', 'ID20', 'ID22', 'ID24'};

% Data parameters
numTimePoints = 1008;  % Number of data points (every half hour)
numIDs = length(IDs);

% Initialize matrix to store data for each ID
Z_known_all = NaN(numTimePoints, numIDs);

% Extract data for each ID
for i = 1:numIDs
    idData = data(strcmp(data{:, 1}, IDs{i}), :);
    if size(idData, 1) >= numTimePoints
        Z_known_all(:, i) = idData{1:numTimePoints, 2};
    else
        warning('ID %s has insufficient data for %d points!', IDs{i}, numTimePoints);
    end
end

% Known points' coordinates for 12-point grid
x_known = [0, 382.4, 382.4, 0, ...
           995.3, 1186.5, 1186.5, 995.3, ...
           2295.8, 1913.4, 1913.4, 2295.8];
y_known = [0, 163.1, 370, 531.6, ...
           0, 209.3, 370, 531.6, ...
           0, 163.1, 370, 531.6];

% Coordinate matrix for training data
X_known = [x_known', y_known'];

% Generate dense grid for prediction
[Xq, Yq] = meshgrid(0:10:2295.8, 0:10:531.6);
gridPoints = [Xq(:), Yq(:)];

% Define start time (data from 2024/07/29-00:00, every half hour)
startTime = datetime('2024/07/29-00:00', 'InputFormat', 'yyyy/MM/dd-HH:mm');

% Define GIF filename
gifFilename = 'humidity.gif';

% Loop over odd time points to create hourly frames
for t = 1:2:numTimePoints
    frameIndex = (t+1)/2;
    currentTime = startTime + hours(frameIndex-1);
    timeStr = datestr(currentTime, 'yyyy/mm/dd-HH:MM');
    
    % Get humidity values for current time point
    Z_known_t = Z_known_all(t, :)';
    
    % Train Gaussian Process Regression model
    gprModel = fitrgp(X_known, Z_known_t, 'KernelFunction', 'squaredexponential', 'Sigma', 1.0);
    
    % Predict humidity on dense grid
    Zq_pred = predict(gprModel, gridPoints);
    Zq_pred = reshape(Zq_pred, size(Xq));

    % Set humidity limits
    min_temp = min(Z_known_t);
    max_temp = max(Z_known_t);
    Zq_clipped = max(min(Zq_pred, max_temp + 2), min_temp - 2);
    
    % Create hidden figure
    fig = figure('visible', 'off', 'Position', [100, 100, 900, 600]);
    surf(Xq, Yq, Zq_clipped);
    shading interp;
    colormap jet;
    cb = colorbar;
    pos = get(cb, 'Position');
    pos(1) = pos(1) + 0.09;
    pos(2) = pos(2) + 0.05;
    set(cb, 'Position', pos);
    caxis([38, 100]);
    title([timeStr, ' Greenhouse humidity']);
    xlabel('Length (cm)');
    ylabel('Width (cm)');
    zlabel('Humidity (%)');
    view(30, 45);
    hold on;
    
    % Label known points with measured values
    Z_offset = max_temp + 0.25;
    for i = 1:length(Z_known_t)
        text(x_known(i), y_known(i), Z_offset, ...
            sprintf('%.1f%', Z_known_t(i)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', 10, 'Color', 'black', 'FontWeight', 'bold');
    end
    zlim([38, 105]);
    set(gca, 'XDir', 'reverse');
    daspect([1 0.7 0.05]);
    hold off;
    drawnow;
    
    % Save frame to GIF
    frame = getframe(fig);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);
    if t == 1
        imwrite(imind, cm, gifFilename, 'gif', 'Loopcount', inf, 'DelayTime', 0.417);
    else
        imwrite(imind, cm, gifFilename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.417);
    end
    close(fig);
end