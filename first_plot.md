
```matlab
disp('hello matlab')
```

```matlabTextOutput
hello matlab
```

```matlab

%% Sine Wave Plot
% This script generates and plots a sine wave.

% Define the time axis
t = 0:0.01:2*pi;

% Compute sine wave
y = sin(t);

% Plot
plot(t, y, 'LineWidth', 1.5);
xlabel('Time (radians)');
ylabel('Amplitude');
title('Sine Wave');
grid on;
```

![sine_wave_plt.png](sine_wave_plot)


