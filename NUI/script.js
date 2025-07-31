let selectedOption = null;
let uiVisible = false;

document.addEventListener("DOMContentLoaded", () => {
    // Handle option selection
    document.querySelectorAll(".option").forEach((option) => {
        //console.log("Option element found:", option);


        option.addEventListener("click", () => {
            document.querySelectorAll(".option").forEach((opt) => opt.classList.remove("selected"));
            option.classList.add("selected");
            selectedOption = option.getAttribute("data-value");

            fetchToLua({option: selectedOption}, 'changeOption');
           
        });

    });



    // Handle Start button
    const startButton = document.querySelector(".button.start");
    if (startButton) 
        startButton.addEventListener("click", () => fetchToLua({ action: "hideUI" }, 'Start'));
    

    // Handle Exit button
    const exitButton = document.querySelector(".button.exit");
    if (exitButton) 
        exitButton.addEventListener("click", () => fetchToLua({ action: "hideUI" }, 'Exit'));

    // Handle Escape key
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape') {
            fetchToLua({ action: "hideUI" }, 'Exit');
        }
    });
});



function fetchToLua(data, callback) {
    let url;

    if(callback === 'Exit') {
        url = `https://${GetParentResourceName()}/Exit`;
    }
    else if(callback === 'Start') {
        url = `https://${GetParentResourceName()}/Start`;
    }
    else if(callback === 'changeOption') {
        url = `https://${GetParentResourceName()}/changeOption`;
    }
    
    fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify(data),
    });
}

function cleaningUI(){
    const container = document.querySelector(".container");
    container.style.display = "none"; // Hide the UI
    document.querySelector(".cHud").style.display = "none";
    selectedOption = null; // Reset selected option
    document.querySelectorAll(".option").forEach((opt) => opt.classList.remove("selected")); // Remove selection from options
    uiVisible = false; // Reset the uiVisible flag
}

// Listen for NUI messages to show/hide UI
window.addEventListener("message", (event) => {
    if(event.data.type === "ui" && !uiVisible){
        if(event.data.status === true ) {
            console.log("Showing UI with config:", event.data.config);
            document.querySelector(".container").style.display = "block";
            document.querySelector(".cHud").style.display = "block";
        }
        uiVisible = true; // Set UI visible flag
    }    
    else if(event.data.type === "hideUI" && uiVisible) {
        cleaningUI();
    }
    else{
        console.log("Unknown message type or UI already hidden.");
    }
});
