<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username  = (String) request.getAttribute("username");
    int    leaveId   = (Integer) request.getAttribute("leaveId");
    String leaveType = (String)  request.getAttribute("leaveType");
    String startDate = (String)  request.getAttribute("startDate");  // yyyy-MM-dd
    String endDate   = (String)  request.getAttribute("endDate");
    String reason    = (String)  request.getAttribute("reason");
    if (reason == null) reason = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Leave - SANI BUS</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.css"/>
    <style>
        :root {
            --pink-bg: #d8a19a;
            --dark-brown: #2b1c1a;
            --white: #ffffff;
            --light-text: #8c7673;
            --border-light: #f0e8e6;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background-color: var(--pink-bg); min-height: 100vh; }

        /* NAV */
        .top-nav { display: flex; justify-content: space-between; align-items: center; padding: 12px 50px;
                   background: rgba(255,255,255,0.15); backdrop-filter: blur(10px);
                   border-bottom: 1px solid rgba(255,255,255,0.1); }
        .nav-left { display: flex; align-items: center; gap: 10px; }
        .nav-left .bus-logo { background: #fff; padding: 5px 8px; border-radius: 8px; font-size: 18px; }
        .nav-left .brand-name { font-weight: 800; font-style: italic; font-size: 22px; color: var(--dark-brown); }
        .nav-right { display: flex; align-items: center; gap: 12px; }
        .user-meta { text-align: right; display: flex; flex-direction: column; }
        .user-name  { font-weight: 800; color: var(--dark-brown); font-size: 14px; }
        .user-role  { font-size: 9px; font-weight: 600; color: var(--light-text); text-transform: uppercase; }
        .avatar-container { background: white; width: 40px; height: 40px; border-radius: 10px;
                            display: flex; align-items: center; justify-content: center; color: var(--dark-brown); }

        /* CONTENT */
        .main-content { max-width: 860px; margin: 0 auto; padding: 40px 40px; }
        .back-link { display: inline-flex; align-items: center; gap: 8px; color: var(--dark-brown);
                     font-weight: 700; font-size: 13px; text-decoration: none; margin-bottom: 20px;
                     background: rgba(255,255,255,0.4); padding: 8px 16px; border-radius: 10px; }
        .back-link:hover { background: rgba(255,255,255,0.6); }
        .page-header { margin-bottom: 28px; }
        .page-header h1 { font-size: 26px; font-weight: 800; color: var(--dark-brown); }
        .page-header p  { color: var(--light-text); font-size: 13px; margin-top: 4px; }

        /* CARD */
        .edit-card { background: white; border-radius: 20px; padding: 35px;
                     box-shadow: 0 8px 30px rgba(0,0,0,0.06); }
        .form-row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 25px; margin-bottom: 25px; }
        .form-group label { font-size: 10px; font-weight: 700; color: var(--light-text);
                            letter-spacing: 1px; text-transform: uppercase; display: block; margin-bottom: 8px; }
        .form-group select,
        .form-group input[type="date"],
        .form-group input[type="file"],
        .form-group textarea {
            width: 100%; padding: 12px 15px; border: 1px solid var(--border-light);
            border-radius: 12px; font-family: 'Poppins', sans-serif; font-size: 14px;
            color: var(--dark-brown); outline: none; background: #fff;
        }
        .form-reminder { background: #fcf8e3; border-left: 4px solid #f0ad4e; color: #8a6d3b;
                         padding: 12px 15px; margin-bottom: 25px; border-radius: 0 12px 12px 0;
                         font-size: 12px; font-weight: 600; display: flex; align-items: center; gap: 10px; }
        .total-days-box { display: none; background: #eaf4fb; border-left: 4px solid #3498db;
                          padding: 12px 18px; border-radius: 0 12px 12px 0; margin-bottom: 25px;
                          font-size: 13px; font-weight: 700; color: #1a5276; }
        .btn-row { display: flex; gap: 12px; align-items: center; }
        .submit-btn { background: var(--dark-brown); color: white; border: none; padding: 14px 30px;
                      border-radius: 12px; font-weight: 700; font-size: 14px; cursor: pointer;
                      display: flex; align-items: center; gap: 10px; }
        .cancel-btn { background: transparent; color: var(--dark-brown); border: 1.5px solid var(--dark-brown);
                      padding: 13px 28px; border-radius: 12px; font-weight: 700; font-size: 14px;
                      cursor: pointer; text-decoration: none; display: flex; align-items: center; gap: 8px; }
        .cancel-btn:hover { background: rgba(43,28,26,0.06); }
    </style>
    <link rel="stylesheet" href="sani-theme.css">
</head>
<body>

<nav class="top-nav">
    <div class="nav-left">
        <span class="bus-logo">&#x1F68C;</span>
        <span class="brand-name">SANIBUS</span>
    </div>
    <div class="nav-right">
        <div class="user-meta">
            <span class="user-name"><%= username %></span>
            <span class="user-role">DRIVER</span>
        </div>
        <div class="avatar-container"><i class="fa-regular fa-user"></i></div>
        <a href="LogoutServlet" style="color:var(--dark-brown); margin-left:10px;">
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
        </a>
    </div>
</nav>

<div class="main-content">

    <a href="driver_home.jsp?tab=leave" class="back-link">
        <i class="fa-solid fa-arrow-left"></i> Back to Leave Management
    </a>

    <div class="page-header">
        <h1><i class="fa-solid fa-pen-to-square"></i> Edit Leave Request</h1>
        <p>Modify your pending leave — changes take effect immediately upon saving.</p>
    </div>

    <div class="edit-card">
        <div class="form-reminder" id="formReminder">
            <i class="fa-solid fa-triangle-exclamation"></i>
            <span id="reminderText">Loading…</span>
        </div>

        <form action="EditLeaveServlet" method="POST" enctype="multipart/form-data"
              id="editForm" onsubmit="return validateForm()">
            <input type="hidden" name="leaveId" value="<%= leaveId %>">

            <div class="form-row">
                <div class="form-group">
                    <label>LEAVE TYPE</label>
                    <select name="leaveType" id="leaveType" onchange="handleLeaveTypeChange()">
                        <option value="Emergency" <%= "Emergency".equalsIgnoreCase(leaveType) ? "selected" : "" %>>Emergency Leave</option>
                        <option value="Annual"    <%= "Annual".equalsIgnoreCase(leaveType)    ? "selected" : "" %>>Annual Leave</option>
                        <option value="Medical"   <%= "Medical".equalsIgnoreCase(leaveType)   ? "selected" : "" %>>Medical Leave</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>START DATE</label>
                    <input type="hidden" name="startDate" id="startDate" value="<%= startDate %>">
                    <input type="text"   id="startDateDisplay" placeholder="dd/mm/yyyy"
                           autocomplete="off" readonly
                           style="width:100%;padding:12px 15px;border:1px solid var(--border-light);border-radius:12px;font-family:'Poppins',sans-serif;font-size:14px;color:var(--dark-brown);outline:none;background:#fff;cursor:pointer;">
                </div>
                <div class="form-group">
                    <label>END DATE</label>
                    <input type="hidden" name="endDate" id="endDate" value="<%= endDate %>">
                    <input type="text"   id="endDateDisplay" placeholder="dd/mm/yyyy"
                           autocomplete="off" readonly
                           style="width:100%;padding:12px 15px;border:1px solid var(--border-light);border-radius:12px;font-family:'Poppins',sans-serif;font-size:14px;color:var(--dark-brown);outline:none;background:#fff;cursor:pointer;">
                </div>
            </div>

            <div class="total-days-box" id="totalDaysBox">
                <i class="fa-solid fa-calendar-days"></i>
                Total Leave Duration: <span id="totalDaysText">-</span>
            </div>

            <div style="display:grid; grid-template-columns:1fr 1fr; gap:25px; margin-bottom:25px;">
                <div class="form-group" id="reasonGroup">
                    <label id="reasonLabel">REASON JUSTIFICATION <span style="color:#e74c3c;">*Required</span></label>
                    <textarea name="reason" id="reason"
                              placeholder="Type a contextual explanation for verification..."><%= reason %></textarea>
                </div>
                <div class="form-group" id="proofGroup" style="display:none;">
                    <label id="proofLabel">REPLACE PROOF DOCUMENT (PDF ONLY)</label>
                    <input type="file" name="leaveProof" id="leaveProof" accept="application/pdf">
                    <span style="font-size:11px; color:var(--light-text); display:block; margin-top:5px;">
                        Leave blank to keep the existing MC on file.
                    </span>
                </div>
            </div>

            <div class="btn-row">
                <button type="submit" class="submit-btn">
                    <i class="fa-solid fa-floppy-disk"></i> Save Changes
                </button>
                <a href="driver_home.jsp?tab=leave" class="cancel-btn">
                    <i class="fa-solid fa-xmark"></i> Discard
                </a>
            </div>
        </form>
    </div>
</div>

<script>
function handleLeaveTypeChange() {
    var leaveType    = document.getElementById('leaveType').value;
    var reasonGroup  = document.getElementById('reasonGroup');
    var proofGroup   = document.getElementById('proofGroup');
    var reminderText = document.getElementById('reminderText');
    var reasonInput  = document.getElementById('reason');
    var fileInput    = document.getElementById('leaveProof');

    if (leaveType === 'Medical') {
        reasonGroup.style.display = 'none'; proofGroup.style.display = 'block';
        reasonInput.value = '';
        document.getElementById('proofLabel').innerHTML =
            "REPLACE PROOF DOCUMENT (PDF ONLY)";
        reminderText.innerHTML =
            "<strong>Medical leaves</strong> require an official Medical Certificate. Upload a new PDF to replace the existing one, or leave blank to keep it.";
    } else if (leaveType === 'Annual') {
        reasonGroup.style.display = 'none'; proofGroup.style.display = 'none';
        reasonInput.value = ''; if (fileInput) fileInput.value = '';
        reminderText.innerHTML =
            "<strong>Annual leaves</strong> do not require a reason. Adjust your dates and save.";
    } else {
        reasonGroup.style.display = 'block'; proofGroup.style.display = 'none';
        if (fileInput) fileInput.value = '';
        document.getElementById('reasonLabel').innerHTML =
            "REASON JUSTIFICATION <span style='color:#e74c3c;'>*Required</span>";
        reminderText.innerHTML =
            "<strong>" + leaveType + " leaves</strong> require a detailed reason justification.";
    }
}

var fpStart, fpEnd;

function recalcDays() {
    var startVal = document.getElementById('startDate').value;
    var endVal   = document.getElementById('endDate').value;
    var box  = document.getElementById('totalDaysBox');
    var text = document.getElementById('totalDaysText');
    if (startVal && endVal) {
        var diff = Math.round((new Date(endVal) - new Date(startVal)) / 86400000) + 1;
        text.textContent = diff + (diff === 1 ? ' day' : ' days');
        box.style.display = 'flex'; box.style.alignItems = 'center'; box.style.gap = '10px';
    } else {
        box.style.display = 'none';
    }
}

function initDatePickers() {
    var today        = new Date();
    // Read existing yyyy-MM-dd values from hidden fields to pre-populate pickers
    var existingStart = document.getElementById('startDate').value || null;
    var existingEnd   = document.getElementById('endDate').value   || null;

    fpStart = flatpickr('#startDateDisplay', {
        dateFormat:    'd/m/Y',
        allowInput:    false,
        disableMobile: true,
        minDate:       today,
        defaultDate:   existingStart,   // pre-fill with saved value
        onChange: function(selectedDates) {
            var d = selectedDates[0];
            if (d) {
                var iso = d.getFullYear() + '-' +
                          String(d.getMonth()+1).padStart(2,'0') + '-' +
                          String(d.getDate()).padStart(2,'0');
                document.getElementById('startDate').value = iso;
                if (fpEnd) fpEnd.set('minDate', d);
            } else {
                document.getElementById('startDate').value = '';
            }
            recalcDays();
        }
    });

    fpEnd = flatpickr('#endDateDisplay', {
        dateFormat:    'd/m/Y',
        allowInput:    false,
        disableMobile: true,
        minDate:       existingStart ? new Date(existingStart) : today,
        defaultDate:   existingEnd,
        onChange: function(selectedDates) {
            var d = selectedDates[0];
            if (d) {
                var iso = d.getFullYear() + '-' +
                          String(d.getMonth()+1).padStart(2,'0') + '-' +
                          String(d.getDate()).padStart(2,'0');
                document.getElementById('endDate').value = iso;
            } else {
                document.getElementById('endDate').value = '';
            }
            recalcDays();
        }
    });
}

function calculateDays() { recalcDays(); }

function validateForm() {
    var leaveType   = document.getElementById('leaveType').value;
    var reasonInput = document.getElementById('reason').value.trim();
    var fileInput   = document.getElementById('leaveProof');
    var startVal    = document.getElementById('startDate').value;
    var endVal      = document.getElementById('endDate').value;
    if (!startVal || !endVal) { alert("Please select both a start and end date."); return false; }
    if (endVal < startVal)    { alert("End date cannot be before start date."); return false; }
    if (leaveType === 'Emergency' && reasonInput === '') {
        alert("Please provide a reason justification for Emergency Leave."); return false;
    }
    return true;
}

window.addEventListener('DOMContentLoaded', function () {
    initDatePickers();        // Flatpickr with pre-loaded dates
    handleLeaveTypeChange();  // set visible fields based on pre-selected type
    recalcDays();             // show duration if both dates already set
});
</script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.js"></script>
</body>
</html>