%Class used by the frame work to store data acquired from the agent,
%task, or frame work. In order to store properties, the data store classs
%makes use of dynamic properties. These dynamic properties may be queried
%using standard dot '.' notation. The list of dynamic properties stored in
%the data store can be determined by reading the cell array recordList.
%Each element of recordList contains the string literal of a class property
%recorded within the data store. The dimensions on an individual instance
%of a property within the data store can be determined by querying the structure
%storeDimensions by the property name. For each property stored within the
%data data store DS.numPoints elements each of size
%storeDimensions.property exist. Individual time steps are indexed by the
%last dimension of the data store. For example, scalars are stored as row
%vectors of size [1,numPoints], vectors are stored as matricies
%[n,numPoints], matricies are stored as 3 dimensional matricies of size
%[n,m, numPoints], etc. Whether explicity instructed to be recorded or not,
%each data store contains a record of the time step at which all other
%points were recorded. 

%In order to construct an instance of DataStore, a reference to the object
%to be recorded, the number of time steps to be recorded, and a list of
%publically accessible class properties must be provided. DataStore
%initiation is typically done by the framework and can be ignored by the
%user in most circumstances.

classdef DataStore < dynamicprops
    %**********************************************************************
    %USER ACCESSIBLE PROPERTIES
    %**********************************************************************
    properties (SetAccess = protected, GetAccess = public)
        recordList %the list of variables to record
        storeDim %a structure containing the size of each stored atrribute for one time step
        numPoints %the total number of time steps
        
        step %an array equivalent to 1:numPoints
    end
    
    %**********************************************************************
    %USER ACCESSIBLE CLASS CONSTUCTOR
    %**********************************************************************
    methods
        %Method which constructs a data store object for data recording
        %purposes.
        
        %INPUT
        %OBJ:           The object to be recorded
        %recordList:    The variables from the object to record
        %numPoints:     The total number of time steps to be recorded
        function DS = DataStore(OBJ, recordList, numPoints)
            
            %Check that OBJ is a valid object
            if isobject(OBJ) ~= 1
                error('DataStore:Constructor', 'Error: The Object provided is not a valid matlab object');
            end
            
            DS.OBJ = OBJ;
            
            %Check that there are nu duplicates in record list
            if length(unique(recordList)) ~= length(recordList)
                error('DataStore:Constructor', 'Error: The list of variables to record contains duplicate entries');
            end
            
            %Check that each element of record list is a valid publically
            %accesible property in OBJ
            attributes = properties(OBJ);
            for i = 1:length(recordList)
                if ismember(recordList{i}, attributes) ~= 1
                    error('DataStore:Constructor', 'Error: Record List element not a publically accessible attribute');
                end
            end
            
            DS.recordList = recordList;
            
            %Check that the number of points is a properly defined integer
            if isinf(numPoints) || isnan(numPoints) || isscalar(numPoints) ~= 1 || numPoints - floor(numPoints) ~= 0
                error('DataStore:Constructor', 'Error: The number of sampling points provided must be an integer');
            end
            
            %Generate vectors and matricies which will store the data
            DS.numPoints = numPoints;
            DS.genDataStore(numPoints);
        end
    end
    
    %**********************************************************************
    %FRAMEWORK PROPERTIES AND METHODS. IGNORE
    %**********************************************************************
    
    properties (SetAccess = protected, GetAccess = protected)
        OBJ %the object whose data is to be recorded
        storeWrite %Structure of paramaters used for object and structure assignment using subsasgn
    end
    
    methods
        %A function which records the publically accessible variables from
        %OBJ indicated in recordList to the current data store.
        
        %INPUT
        %step:  The current time step
        record(DS, step);
        
        %a function which preallocates the memory required to record the
        %indicated variables for the entirety of the simulation
        
        %INPUT
        
        %numPoints:     The number of time steps.
        genDataStore(DS, numPoints);
    end
end

