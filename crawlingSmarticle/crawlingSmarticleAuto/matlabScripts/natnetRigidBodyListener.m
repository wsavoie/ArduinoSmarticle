function natnetRigidBodyListener( ~ , evnt)
%NATNETRIGIDBODYLISTENER % Function to construct and configure a rigid body
%listener for the NatNet client.

% The eventcallback function executes each time a frame of mocap data is 
% delivered to Matlab. Matlab will lag if the data rate from the Host is
% too high.

% Andras Karsai, June 2017

%   Number of rigid bodies
%     clc;
    rbnum = 2;
    
%   Calls the frame
%     datatowrite = zeros(rbnum+1,3);
    frame = evnt.data.iFrame;
    
%   Instantiates an array of positions
    posarr = zeros(3,rbnum);
    
    for i = 1:rbnum
        rb = evnt.data.RigidBodies(i);
%   Outputs the position of the rigid body in mm.
        posarr(:,i) = double(([rb.x, rb.y, rb.z]) * 1000);
    end

%   Creates a rigid body object
%   Formats the data for stream writing  
%     reshaped = reshape(posarr,1,rbnum*3);
%     datatowrite = [frame, reshaped];
%     
%   Find the UDP Client object (since it cannot be passed into this
%   listener callback.
%     udpc = instrfind('Type', 'udp', 'RemoteHost', '127.0.0.1', 'RemotePort', 21021, 'Tag', '');
    
%   Writes the data into the stream.  
%     fprintf(udpc, num2str(datatowrite));
%      disp(datatowrite);
end
