
//--------------------------------------//
// SAR VV band imagecollection 
// Filter on location and polarization
var Sen1VVImgCol = S1.filter(ee.Filter.eq('instrumentMode', 'IW'))
                    .filter(ee.Filter.listContains('transmitterReceiverPolarisation', 'VV'))
                    .filterBounds(myAOI)
                    .select('VV');

// Constant setup
var startDate=ee.Date('2018-01-01');
var endDate  =ee.Date('2018-12-31');

// Create yearly SAR VV image reducer by max and intevalmean 
var Sen1VVImg_Max=Sen1VVImgCol.filterDate(startDate,endDate).reduce(ee.Reducer.max());

var Sen1VVImg_IntMean=Sen1VVImgCol.filterDate(startDate,endDate).reduce(ee.Reducer.intervalMean(80,100));


// Offshore wind farm filter by Half Min-Max theshold
// Reduce the region. The region parameter is the Feature geometry.
var AOI_MaxValue = Sen1VVImg_IntMean.reduceRegion({
  reducer: ee.Reducer.max(),
  geometry: Grid,
  scale: 30,
  maxPixels: 1e9
});
// Reduce the region. The region parameter is the Feature geometry.
var AOI_MinValue = Sen1VVImg_IntMean.reduceRegion({
  reducer: ee.Reducer.min(),
  geometry: Grid,
  scale: 30,
  maxPixels: 1e9
});
// Reduce the region. The region parameter is the Feature geometry.
var AOI_MeanValue = Sen1VVImg_IntMean.reduceRegion({
  reducer: ee.Reducer.mean(),
  geometry: Grid,
  scale: 30,
  maxPixels: 1e9
});
// Set the Half min-max threshold
var max1= ee.Number(AOI_MaxValue.getNumber('VV_mean'));
var min1= ee.Number(AOI_MinValue.getNumber('VV_mean'));
var Min_Max = max1.subtract(min1).multiply(0.5);
var OWF_Thershold =  max1.subtract(Min_Max);
print(OWF_Thershold);

// Get offshore wind farm image filter by Half min-max threshold
var Sen1VVImg_OWF = Sen1VVImg_IntMean.gt( OWF_Thershold);
print(Sen1VVImg_OWF);


// Offshore wind Farm morphological open ersion and dialte
// Define kernel and Perform an erosion followed by a dilation, display.
var minKernel = ee.Kernel.circle({radius: 1});

// Perform an erosion followed by a dilation, display.
var Sen1VVImg_OWFOpened =  Sen1VVImg_OWF
             .focal_min({kernel:minKernel, iterations: 2})
             .focal_max({kernel: minKernel, iterations: 2});
print(Sen1VVImg_OWFOpened);

// Area filter 
// Compute the number of pixels in each patch < 128 and >20 will be show
var Sen1VVImg_OWFPatchsize = Sen1VVImg_OWFOpened.connectedPixelCount(256, true);
var ImageOWF = Sen1VVImg_OWFPatchsize.lt(200).and(Sen1VVImg_OWFPatchsize.gt(20));


// Mapping layer
Map.centerObject(Grid, 10);
Map.addLayer(Sen1VVImg_IntMean, {min: -20, max: 20},"meanyearly");
Map.addLayer(Sen1VVImg_Max, {min: -20, max: 20},"maxyearly");
Map.addLayer(ImageOWF.updateMask(ImageOWF), {color: 'FF0000'}, 'ImageOWF',0);
Map.addLayer(Sen1VVImg_OWFOpened.updateMask(Sen1VVImg_OWFOpened), {min: 0, max: 1}, 'swf_opend',0);


// Convert offshore wind farm from raster to vectors and export 
var OWFFeaCol = ImageOWF.addBands(Sen1VVImg_OWFPatchsize).reduceToVectors({
  geometry: Grid,
  crs: ImageOWF.projection(),
  scale: 8,
  geometryType: 'centroid',
  eightConnected: true,
  labelProperty: 'zone',
  reducer: ee.Reducer.median(),
  bestEffort:true,
  maxPixels:1e15
});

print(OWFFeaCol);

//---------------------//
// Output the result
Export.table.toDrive({
 collection:   OWFFeaCol,
 folder: 'GEE-Export',
 description: 'OWFfeaturecollectionToDrive',
 fileFormat:  'SHP'
});


