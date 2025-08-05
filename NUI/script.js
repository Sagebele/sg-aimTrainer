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
    })    

    // Handle Start button & Enter
    const startButton = document.querySelector(".button.start");
    if (startButton){
        startButton.addEventListener("click", () => 
        fetchToLua({ action: "hideUI" }, 'Start'));
        
    }    
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Return') {
            fetchToLua({ action: "hideUI" }, 'Start')
            
        }
    });

    // Handle Exit button
    const exitButton = document.querySelector(".button.exit");
    if (exitButton){ 
        exitButton.addEventListener("click", () => 
        fetchToLua({ action: "hideUI" }, 'Exit'));
    }    
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
    document.querySelector(".closeHud").style.display = "none";
    selectedOption = null; // Reset selected option
    document.querySelectorAll(".option").forEach((opt) => opt.classList.remove("selected")); // Remove selection from options
    uiVisible = false; // Reset the uiVisible flag
}

// Listen for NUI messages to show/hide UI
window.addEventListener("message", (event) => {
    if(event.data.type === "ui" && !uiVisible){
        uiVisible = true; // Set UI visible flag
        if(event.data.status === true ) {
            console.log("Showing UI with config:", event.data.config);
            document.querySelector(".container").style.display = "block";
            document.querySelector(".closeHud").style.display = "block";
        }
        
    }    
    else if(event.data.type === "hideUI" && uiVisible) {
        cleaningUI();
    }


    if(event.data.type === "killCounterUpdate"){
        document.getElementById("killCountValue").textContent = event.data.value;
        document.querySelector(".killCounter").style.display = "block";
    }
    else if(event.data.type == "hideKillCounter"){
        document.querySelector(".killCounter").style.display = "none";
        document.getElementById("killCountValue").textContent = 0;
    }    
});
