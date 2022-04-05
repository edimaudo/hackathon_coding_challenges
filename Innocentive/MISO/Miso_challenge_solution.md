## THE CHALLENGE
MISO envisions a future where resource maintenance and outage scheduling is handled in a more automated, self-service environment. In this future, the entire needs of asset maintenance are captured and optimized. The future capabilities of MISO’s operations need to reduce human dependencies and still operate with the highest reliability and efficiency possible.
Specifically, MISO seeks to improve in the following areas:

- How does MISO increase the certainty around outages?
- How do we minimize dependence on MISO staff?
- What technologies would lead to greater predictability and accuracy? How could we implement those?
- What mathematical models or algorithms could be applied to MISO’s outage coordination process?
- What would simplify the process?

Any proposed solution should address the following Solution Requirements: 
- Allows resource down time while protecting system integrity by ensuring a minimum quality of available resources
- Balances overall system integrity with fairness to individual resource owners in allowing for routine maintenance
- Integrates the request, analysis, and scheduling functions while allowing visibility of availability to requestors.

Provide detailed and specific guidance on how to implement major components of the proposed solution and how each component interacts with the other components, including stakeholder systems and input.
The solutions would preferably satisfy the additional following criteria (but not essential):
- Provides insight into how other industries handle scheduled and unscheduled maintenance in high reliability environments.

## Project Criteria
Submitted proposals along with all relevant supporting data should include the information described in the Detailed Description of the Challenge. The solution may combine existing components, commercially available components, and/or novel Solver solutions. Ideas leveraged from other industries with similar problems are encouraged.

The submitted proposal must be written in English and should include the following:
1) An Abstract and optional Conclusion.
2) Detailed description of an approach to an outage coordination system that can meet the above Solution Requirements. This must include:
a) A detailed block diagram/wireframe view of the proposed system with major components and information flow indicated
b) Specific details of each component and how to implement the functionality of the component. This may include custom or commercial software, and in the case of custom software a detailed description of the algorithm and architecture is required
c) Detailed narratives for different outage request scenarios beginning with a request from a participant. Narratives must describe the information flow between components, the decision process within relevant components, and the operation of each component utilized in the scenario. Scenarios must include:
- A simple outage request that can be approved automatically
- An outage request that requires a full outage study and is approved
- An outage request that is denied
3) Rationale as to why the Solver believes that the proposed system will work. This rationale should address each of the Solution Requirements described in the Detailed Description and should be supported with any relevant examples and/or scenarios.
4) Data, drawings etc. necessary to convey the full extent of the proposed solution.

# SOLUTION SUMMARY

## Solution Name
MOMS - Miso Outage Management System

## Solution Abstract
 

## Solution conlusion


#--------------------
# SOLUTION IN DETAIL
#--------------------

## Overview
MISO (Midcontinent Independent System Operator) is an independent, not-for-profit, member-based organization that delivers safe, cost-effective electric power across 15 U.S. states and the Canadian province of Manitoba. A major service they provide is the coordination of scheduled and unscheduled outages of electricity generation and transmission assets. These assets are controlled by various stakeholders and must occasionally be taken offline for maintenance and repair.  The current process for scheduling outages and coordinating with different stakeholders is cumbersome.  
The goal is to develop a new system that would assist MISO in meeting these criteria:
- Increase the certainty around outages
- Minimize dependence on MISO staff
- Driver greater predictability and accuracy
- Simplify the outage coordination process
- Simplify the overall process

## Solution
The solution that would solve these challenges is MOMSP.  MOMSP stands for MISO Outage Mangement System & Processes.  It encompasses two key areas:
- outage management system (OMS)
- outage management processes

## Why would it be needed
The status quo is not going to be effective moving forward as the supply fo power is being impacted by different factors such as: (https://www.ge.com/digital/blog/riding-storm-network-digital-twin-enhance-electric-grid-reliability-resiliency)
- Climate change is increasing the frequency and magnitude of severe weather events
- Aging infrastructure is increasingly vulnerable to forced outages
An OMS is any type of software or computing device that assists in locating, analyzing, and fixing an outage on the energy grid.  OMS operates within the context of individual utilities, they are often able to coordinate with many different sources of data in order to get an accurate image of the grid in real-time. Some key sources that enable an OMS to function are a Geographical Information System (GIS), a Customer Information System (CIS), Automated Metering Infrastructure (AMI), Mobile Workforce Management Systems (MWM), and Supervisory Control and Data Acquisition Systems (SCADA). 
Some features of an OMS can include but are not limited to, automatically reading grid data to determine an outage, alerting utility operators of any outages, and sending notifications to nearby field crews to investigate and fix outages. (https://www.awesense.com/what-are-outage-management-systems-oms/)

## Benefits ot OMS
- An OMS can make a big difference for your local/national utility and for your own power usage. Using new meter technology like AMI, outages are now detected faster than ever. Combined with a good OMS software, many outages today are fixed without anyone even noticing they occurred. 
- Though many outages are detected when a person loses power in their home and calls up their local utility, a reliable OMS can identify this information and provide a quicker response than waiting for you and your neighbor to dial in. 
- This automated coordination and processing an OMS provides means more reliable power and faster resolution for issues to help keep your home running smoothly.

## Features
It is an integrated set of applications that streamline work processes and improve communications between field and operations personnel. It allows generation and transmission asset owners (and operators) the ability to comprehensively manage all outages and their lifecycles, from planning and operations all the way through reporting to ISO scheduling entities, NERC, etc
OMS features (https://www.ge.com/digital/blog/riding-storm-network-digital-twin-enhance-electric-grid-reliability-resiliency)
has a suite of diverse cross-domain models and multi-disciplinary software applications to holistically and scientifically consider both non-power and power system factors to provide:

Outage Risk Prediction for transmission assets, based on their vulnerabilities to extreme weather conditions
Real Time Unplanned Outage Detection and Real Time Decision Support for optimal planning and prediction of the impact of plans on the state of the grid
Real Time Automated Closed Loop Control for execution of the plans to reliably operate the grid during Emergency
Transmission Outage & Restoration Planner (TORP), a data analytics application, 
along with Real Time Shutdown & Restoration Manager (RTSRM), 
a control room Advanced Energy Management System (AEMS) application

Forced events to minor derates are supported and their detailed information is shared with market operators and regulatory authorities before outages occur and after-the-fact. PCI’s system also tracks the status of requests during different outage phases and allows for quick review and approval.  Further, analytics are included every step of the way for all events. On the transmission side, PCI provides a comprehensive tool kit to manage all grid outages while meeting all NERC requirements. 

Journal Module
Log and track any asset issues. Record chronologies of daily business events, perform regulatory compliance, and track internal workflows.

Scheduling Module
Automate the scheduling process so users can import, review and modify schedule data using PCI’s system or other applications (if desired). Users can verify schedule consistency with outages or derates.

Plant Instructions Module
Enhance communications between dispatchers and field personnel by providing an audited messaging system to support real-time three-way communications.

Plant Interface Module
Plant personnel can review and update operational data driving day-ahead and real-time market offers. They can then monitor and report on market-clearing results and prices in the DA/RT modes.

GADS Module
Better manage NERC GADS compliant outages, derates and reserve shutdown events while making those events available to other PCI or third-party applications.

All data (maps, schematics, asset registers, real-time information, etc.) is stored in the same open relational database with an object-based structure
Complete data models (network models) for different industry applications, including power, heating, gas, telecom, water and wastewater, and more
Unified information and data model for all relevant operations within the organization
Geographical maps, schematics, and drawings
Vector and raster support
Embedded workflow
Scalable from small to huge data/user volumes
Excellent performance
Transformation of geo-coordinates
Thematic mapping
Asset register
Topology/Tracing
Long transactions including revisions management
Export/Import and integration interface
All interfaces/functions accessible using web-based clients
Mobility via field apps
Powerful, rule-based editing
Support for templates, both organization-wide and user-defined
Embedded GIS functionality and project management/workforce management tools

Supported workflows include:

Automatic and semi-automatic planning and design mechanisms
Project management support for scheduling activities and resources
Updated status of activities and objects
Collaboration between back office and field crew
Capacity and bottleneck analysis of network objects
Fault/outage management to support customer communication and service
Planned maintenance

includes tools and methodologies to extract and process bulk import or incremental updates from external, legacy third-party systems and databases. We have nearly 30 years of experience migrating geospatial data from these types of databases.

To support customers deploying a Digpro GIS platform that will serve as the new master for geospatial and/or network data, and who already operate third-party or legacy OMS/DMS systems, we can set up either incremental or transactional updates between the systems.

Customers with existing and/or legacy systems can retain the value of that data by transferring it to Digpro applications. Where necessary, we can provide the needed technical support and services to migrate, transform, or shape existing geospatial data for use in your new systems. 

Those services include:

Support for many GIS data formats
Bulk and/or incremental data migration
Geographic and schematic views
Identify and update deltas
Synchronize attributes
Geo references
Consolidate, aggregate, convert, or transform data
Assure migrated data quality

# Cyber security
As industrial and utility organizations increasingly rely on the web to connect their data sources, security is a top concern. Smart devices and sensors, connected via the Internet of Things, continue to expand the attack surface for potential intruders.

Defending your organization against cyber threats is a top priority for Digpro. We ensure the highest possible levels of security for our software products, systems, and services through an in-depth, multi-layer protection strategy. Some of the security measures in place include:

Documented initiatives, based on and/or aligned with accepted industry standards and practices, to build security into every step of our software development process, including design, implementation, verification, release, and training
On-going activities related to improving software security, including robustness testing, vulnerability scanning, and security testing that encompasses static code and/or binary code analysis
Industry-standard cryptographic tools and security functionality, including:
– Cryptographic algorithms to hash, encrypt, or sign data for storage or transmission.
– Protocols and procedures to support cryptographic algorithms (e.g., to exchange certificates, establish keys, or generate random numbers)
− Functionality to authenticate end users or for access control
Proactively prevent malware propagation, primarily via scans of software deliverables and their storage/delivery media, using the most-current, appropriate antivirus tools
Properly handling and protecting all digital certificates used in software development to sign code or as a root to derive product-specific certificates
The Digpro software platform is highly secure, with data integrity and consistency guaranteed by constraints in the database and the authorization system. All users have unique security credentials, with updates done through “change sets” that allow for long transactions. All updates are verified to ensure compliance with the rules before they are executed. For example, it is impossible to post a cable “In Service” unless the connectivity component exists and shows where the cable is fed from. The authorization system is based on user privileges at a table and column level.

All Digpro applications and software products provide capabilities to integrate third-party security solutions such as firewalls, antivirus, network/host intrusion detection, and security monitoring. Digpro recommends that you leverage our partner network to secure your IT and automation systems with industry-standard malware and intrusion-protection solutions that include anti-virus protection and application whitelisting.

## Tech Setup
platform is a web-based, open system built on industry-standard technology.
base platform includes a unique, purpose-built GIS platform
 integrate the latest innovations in database technology. The advanced, distributed, web-based architecture, built-in GIS engine, and workflow management provide a highly effective tool to manage the big data of utilities of all sizes. All network objects are connected with respect to pre-built physical and logical design rules. Modules and components work together to create a robust, scalable, high-performance system.


Open standards
The Digpro platform is a web-based, open system built on industry-standard technology. Data models comply with OpenGIS specifications for spatial data, and follow relevant IEC specifications for network model data. The system is platform-independent and able to run on virtually any operating system, but is commonly run on both Windows and Linux systems.


Web solution
The web clients require only a standard web browser such as Google Chrome or Internet Explorer supporting HTML5 on any mobile device. The Digpro main user-interface client runs on operating system that supports Java


Scalability
One of the strengths of the Digpro platform lies in its scalability. Thanks to the three-tier architecture design, the middle-logic tier is implemented on a cluster of web servers. All big-data processing is done in the database, resulting in optimal performance. No matter if a customer has only a few users or several thousands, all can simultaneously access the system. If additional user capacity is needed, the system can be effortlessly expanded by adding web servers and growing the database.


Interoperability
Organizations often need to integrate services and data from many different sources and in different formats. They also want to support a wide range of business processes across their organizations. Digpro is committed to the open standards and interoperability that enable this type of environment.

STANDARD PROTOCOLS AND TECHNOLOGIES SUPPORTED:
Data file formats: DGN, DXF (Drawing Exchange Format), DWG (Drawing), GSI, JPEG, KML (Keyhole Markup Language), PNG (Portable Network Graphics), PDF, RDW, Shapefile, SVG, Topocad, TAB (MapInfo), TXY, XLSX
Real-time data exchange (OPC-UA, ICCP*)
Open Geospatial Consortium (OGC) standardized web services (WMS, WFS, WMTS)
W3C web services (SOAP)
Network model import/export (XML, IEC CIM)

INTEGRATIONS AND APIS
Digpro embraces service-oriented architecture (SOA). It implements a wide range of technologies including SOAP web services, enterprise service bus messaging, and others to integrate or exchange data and support business processes across platforms.

Typical platforms and third-party enterprise systems include:
Customer Information System (CIS)
SCADA and other real-time systems, such as ABB Network Manager, Net Control, and ABB MicroSCADA
ERP systems such as SAP, Maximo, and IFS Applications
Meter Data Management System

## Set up benefits
Completely web-based with an easy-to-use, intuitive user interface (UI)
Manage the entire outage lifecycle process, from the field to outage coordinator/dispatcher (outage, derate entry, update, approval, and notifications)
Easily record operating events for anytime-access and auditing
Seamlessly connect to PCI or third-party systems to share approved outage data across your enterprise
Interface with NERC eGADS
Conform to all ISO/RTO and NERC data requirements


## OMS Process

Have outage communication plan - - https://www.pagerduty.com/resources/learn/outage-communication/
overall safety - https://safetymanagementgroup.com/best-practices-for-outage-season/
outage planning - https://www.reliableplant.com/Read/20318/optimizing-outages-through-effective-task-planning
outage coordination current state
 - https://www.pjm.com/-/media/documents/manuals/m38.ashx
 - http://www.oatioasis.com/woa/docs/MISO/MISOdocs/MM_Whitepaper.pdf
 - https://www.caiso.com/Documents/RC0630.pdf
