# 🌿 Greenhouse Environmental Monitoring Dashboard

This project is a real-time greenhouse temperature and humidity visualization dashboard for the NTU smart greenhouse, integrating data collection, cloud visualization, and interactive web display.

---

## 📌 Project Overview

- 🔗 Real-time temperature and humidity data from **Advantech sensors** deployed in **NTU's smart greenhouse**
- 🧪 Data collected via a **Python script** from a **MongoDB** database
- ☁️ Data pushed to **ThingSpeak**, which uses **MATLAB scripts** to generate:
  - 3D surface contour maps
  - 2D line-based contour maps
- 🖥️ A local **HTML-based dashboard** shows the live maps with:
  - Toggle switch for 3D/2D contour map views
  - Refresh button for latest data
- 📽️ A time-series **GIF animation** is also generated from one month of data using **Gaussian Process Regression**, illustrating environmental trends over time

---

## 🔧 Technologies Used

- **Python**: data collection, preprocessing, model fitting (GPR), and data push to ThingSpeak
- **ThingSpeak + MATLAB**: contour map rendering and URL embedding
- **HTML/CSS/JavaScript**: interactive visualization webpage
- **MongoDB**: sensor data storage
- **Gaussian Process Regression**: spatial interpolation over time
- **Matplotlib + imageio**: animated GIF generation

---

## 🌐 Web Dashboard

| Mode | Screenshot |
|------|------------|
| **3D Contour Map** | ![3D Map](/docs/ContourMap3D_web.png) |
| **2D Contour Map** | ![2D Map](/docs/ContourMapLine_web.png) |

- Buttons:
  - 🔁 **Refresh**: reloads latest plots
  - 🔄 **Switch Visualizations**: toggles between 3D and 2D modes

---

## 📈 Temporal Analysis

Using one month of historical sensor data, **Gaussian Process Regression** is applied to generate smooth spatial estimates of temperature and humidity. Each time snapshot produces a contour map, and the maps are compiled into a **GIF animation** to visualize time-evolving environmental changes in the greenhouse.

---

## 📎 Notes

- Designed for internal use and prototyping purposes in NTU smart greenhouse projects
- All visualization scripts are customizable for different sensor layouts or field deployments
