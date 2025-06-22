% ThingSpeak Channel configuration
channelID = 'channelID';  % Replace with your Channel ID
readAPIKey = 'readAPIKey';  % Replace with your Read API Key

% Read data from ThingSpeak
try
    tempData = thingSpeakRead(channelID, 'Fields', 1:8, 'NumPoints', 1, 'ReadKey', readAPIKey);
catch
    error('Unable to read data from ThingSpeak. Please verify Channel ID and API Key.');
end

% Ensure data is not empty
if isempty(tempData)
    error('No data available.');
end

% Known points' coordinates
x_known = [303, 712, 712, 303];
y_known = [615, 415, 215, 15];

% Unknown points' coordinates
x_unknown = [712, 303, 303, 712];
y_unknown = [615, 415, 215, 15];

% Reshape temperature data into column vector
Z_known = tempData([2; 4; 6; 8]);

% Interpolate to estimate values at unknown points
Z_estimated = griddata(x_known, y_known, Z_known, x_unknown, y_unknown, 'nearest');

% Ensure Z_estimated is a column vector
Z_estimated = Z_estimated(:);

% Combine known and estimated data
Z_all = [Z_known(:); Z_estimated];

% Create 2D grid for interpolation
[Xq, Yq] = meshgrid(0:10:990, 0:10:815);

% Interpolate over combined points for smoother grid
Zq = griddata([x_known, x_unknown], [y_known, y_unknown], Z_all, Xq, Yq, 'cubic');

% Fill NaN values in grid
Zq_filled_X = fillmissing(Zq, 'linear', 2);  % Fill along X-axis
Zq_filled = fillmissing(Zq_filled_X, 'linear', 1);  % Fill along Y-axis

% Set temperature limits
min_temp = min(Z_all);
max_temp = max(Z_all);
Zq_clipped = max(min(Zq_filled, max_temp + 2), min_temp - 2);

Z_offset = max_temp + 0.25;

% Plot 3D surface
figure;
surf(Xq, Yq, Zq_clipped);
shading interp;
colormap jet;
colorbar;
caxis([min_temp - 5 max_temp + 5]);

% Set plot labels and title
title('Temperature');
xlabel('X axis');
ylabel('Y axis');
zlabel('Temperature (°C)');

% Adjust view angle
view(30, 60);

hold on;

% Label known points with temperature values
for i = 1:length(Z_known)
    text(x_known(i), y_known(i), Z_offset, ...
        sprintf('%.1f°C', Z_known(i)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 10, 'Color', 'black', 'FontWeight', 'bold');
end

% Set axis limits
xlim([0, 990]);
ylim([0, 815]);
zlim([min_temp - 10, max_temp + 5]);

hold off;