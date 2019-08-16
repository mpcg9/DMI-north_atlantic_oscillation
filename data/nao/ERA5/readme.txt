data:
- mean sea level pressure data
- monthly
- averaged
- reanalysis
- 1979-2019 (DJF)

nao computation: with cdt-function
iceland_box = select_subset(data, 55, 90, -80, 10);
azores_box = select_subset(data, 30, 50, -80, 10);