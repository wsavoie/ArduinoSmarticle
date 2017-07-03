% natnetInit.m
% Script to initialize the NatNet client in preparation for streaming.

% Andras Karsai, June 2017

% NOTE: Be sure to pen up Motive and setup all your rigid bodies, camera 
% calibration, etc in Motive because it's easier.

% This program uses the NatNet Matlab wrapper and the x64 NatNetML.dll to
% stream from Optitrack into MATLAB using the NatNet protocol to interpret
% Optitrack's native streaming engine.

% This block of code will be called by a 'MATLAB Script' block in Labview
% and stream out the relevant rigid body positions for Labview's use. Make
% sure to keep this environment in accordance with Labview's logic and flow
% structure! Be sure to include the MATLAB path.

% To find more information about the natnet object, use methods('natnet')
% or properties('natnet')

% Change to proper directory and add the dependency library to path
% cd D:\JamesWheels\LabView\OptitrackStream
% addpath('D:\JamesWheels\LabView\OptitrackStream\NatNetSDK')

% Find a udp object.
% udpc = instrfind('Type', 'udp', 'RemoteHost', '127.0.0.1', 'RemotePort', 21021, 'Tag', '');

% Create the udp object if it does not exist
% otherwise use the object that was found.
% if isempty(udpc)a
%     udpc = udp('127.0.0.1', 21021);
% else
%     fclose(udpc);
%     udpc = udpc(1)
% end

% Connect to instrument object, obj1.
% fopen(udpc);
function [client]=natnetInit()
% Creates the natnet client
client = natnet();

% Set the conenction type to the multicast of Optitrack and set the proper
% local loopback IPs.
client.ConnectionType = 'Multicast';
client.ClientIP = '127.0.0.1';
client.HostIP = '127.0.0.1';

% Connect the client object to the streaming server
client.connect();

% Add the relevant listeners to the client
% client.addlistener(1 ,'natnetRigidBodyListener');

% Enable all listeners of the Optitrack client
% client.enable(0);
disp('Now streaming...')
