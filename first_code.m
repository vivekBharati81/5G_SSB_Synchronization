disp('hello vivek')

a = 5;


% Define time vector from 0 to 2*pi with small step
t = 0:0.01:2*pi;

% Compute sine wave
y = sin(t);

% Plot the sine wave
plot(t, y);

% Add labels and title
xlabel('Time (radians)');
ylabel('Amplitude');
title('Sine Wave');

% Add grid for better visibility
grid on;
