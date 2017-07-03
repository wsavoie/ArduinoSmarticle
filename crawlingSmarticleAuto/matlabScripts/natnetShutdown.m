% natnetShutdown.m
% Script to call once streaming is completed to properly shutdown the
% client and its listeners

% Andras Karsai, June 2017

% This program uses the NatNet Matlab wrapper and the x64 NatNetML.dll to
% stream from Optitrack into MATLAB using the NatNet protocol to interpret
% Optitrack's native streaming engine.

% This block of code will be called by a 'MATLAB Script' block in Labview
% and stream out the relevant rigid body positions for Labview's use. Make
% sure to keep this environment in accordance with Labview's logic and flow
% structure!

% To find more information about the natnet object, use methods('natnet')
% or properties('natnet')


% Shuts down all the client's listeners.
disp('Disconnecting...')
client.disable(0);

% Closes the UDP client.
fclose(udpc);
delete(udpc);


% Removing the client from the MATLAB workspace will also disconnet it from
% Optitrack's streaming
clear client;
clear udpc;