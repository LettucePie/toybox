# Toybox
A Virtual Space for Android where players are presented with virtual toys. Toys should all be fairly unique, and are ultimately bi-products of the joy of developing them. This Project also serves as a playground for trying out different features and functions of both Android SDK and Godot Engine.

Made with Godot 4.2.2-stable

As economics continue to get more insane, I have found a refreshed purpose in this project. There's a very real possibility that free apps will become the primary avenue for kids to play. Smartphones appear to be more of a necessity via virtual integrations, and parents want the ability to track/call their kids. So in the scenario where you can buy your kid a smartphone once every couple years or several different toys every few months; kids might not have toys anymore. I suddenly feel importance in providing non-predatory or addictive applications... 

## What is a "Toy"
I think it would be best to define what a Toy is to this project, and all the extra functions it would require to make it a cohesive and understandable.

In the case of this project, a Toy is; 
 - An interactive object. 
 - It most likely will be 3D. 
 - It can have a setting or stage where it's played with if needed. 
   - Table 
   - Box
   - Tub of water 
 - A Toy should not ever load in an entire environment, that would just be a video game. 
 - A Toy can be an object that has a video game on it, akin to very old key-chain games.
 - It does NOT require;
   - Points
   - Timers
   - Conventional Physics
	 - Try to explain or frame unconventional physics in some way.
 - A Toy has its own User Interface options loaded into the universal menu.
   - It can be stylized
 - A Toy can be "focused" into view with it's own camera
   - Camera focus must be escapable
 - A Toy can be an inspired creation off of real life toys and properties.
   - It CANNOT be an exact virtual clone, we don't want to get sued here.
   - It can do similar things, but should not look or sound the same.
 
## How to make a Toy
This app will be using a standardization system for each toy. To briefly understand what is required, read through the "load_toy" function on `play.gd` and the variables of `components/toy_meta.gd`.

 1. Make a folder for your new Toy in `/toys/`.
	- This will contain Scenes, Assets, GUI, and Metadata.
	- Organize your files however you like within your toys folder.
 2. Make a new ToyUI scene within your toy folder.
	- New Scene -> Other Node -> Navigate to `Node > CanvasItem > Control > ToyUI` or just search "toyui".
	- Or you can `extend ToyUI` into your own Control Node UI.
 3. Make a new ToyMeta resource within your toy folder.
	- Right-Click on your toy folder, select Create New Resource, search for ToyMeta.
 4. Make your toy.
	- If your toy has multiple pieces, consider making each piece it's own scene.
	- If your toy will be picked up and moved around alot, consider making its root node my custom class `PickupPhysics`, and add the component scene `PickupRay` as a child. Of course if you need a more intricate solution then go for it. The only necessary components are `ToyUI` and `ToyMeta`.
 5. Fill out the ToyMeta resource.
 6. Load up the Toybox scene `/toybox.tscn`, and append your ToyMeta to the Toy Metadatas array in the inspector.


 ### Feature Ideas
 
 Just jotting some brainstorm stuff down here don't mind me.
 
  - letting users upload panoramas or multiple images to set their own custom worldbox for their play room.
