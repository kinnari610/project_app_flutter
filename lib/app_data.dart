
List<Map<String, String>> getFormsByRole(String role) {
    String normalizedRole = role.toUpperCase();
    if (normalizedRole == "OWNER") {
      return [
        {
          "title": "EA Delegation Form",
          "url": "https://docs.google.com/forms/d/e/1FAIpQLSe4b_hS445A4jlV5isW3NnuAQdGAWjR9xmnsx018I-uofHZEg/viewform"
        },
        {
          "title": "Project Delegation Form JP",
          "url": "https://docs.google.com/forms/d/e/1FAIpQLSdwvcPeuZLQhjR9GuI7nf4m-95gJ_8M2WnACA335KGuVj6gxw/viewform"
        },
        {
          "title": "Design Department Form",
          "url": "https://docs.google.com/forms/d/e/1FAIpQLSd8CJZo9Dna03TuU5KwBoxPdzu-6qE5O9hMClRw9ODNZLHbYA/viewform"
        },
        {
          "title": "Inquiry Quotation Form ",
          "url": "https://docs.google.com/forms/d/e/1FAIpQLSdMm-x99DRtLwMVNTbjkwu1I0TEX44y8n03K4vxBCUzVEmjrg/viewform"
        },
      ];
    }

    /*if (normalizedRole == "MARKETING") {
      return [
        {
          "title": "EA Delegation From",
          "url": "https://docs.google.com/forms/d/e/1FAIpQLSe4b_hS445A4jlV5isW3NnuAQdGAWjR9xmnsx018I-uofHZEg/viewform"
        },
        {
          "title": "Inquiry Quotation From",
          "url": "https://docs.google.com/forms/d/e/1FAIpQLSdMm-x99DRtLwMVNTbjkwu1I0TEX44y8n03K4vxBCUzVEmjrg/viewform"
        },
      ];
    }

    if (normalizedRole == "PRODUCTION") {
      return [
        {
          "title": "Project Delegation From JP",
          "url": "https://docs.google.com/forms/d/e/1FAIpQLSdwvcPeuZLQhjR9GuI7nf4m-95gJ_8M2WnACA335KGuVj6gxw/viewform"
        },
      ];
    }

    if (normalizedRole == "DESIGN") {
      return [
        {
          "title": "Design Department",
          "url": "https://docs.google.com/forms/d/e/1FAIpQLSd8CJZo9Dna03TuU5KwBoxPdzu-6qE5O9hMClRw9ODNZLHbYA/viewform"
        },

      ];
    }*/

    return [];
}

List<Map<String, String>> getSheetsByRole(String role) {
    String normalizedRole = role.toUpperCase();
    if (normalizedRole == "OWNER") {
      return [
        {
          "title": "EA Task Delegation",
          "url": "https://docs.google.com/spreadsheets/d/1123-Yw9w-y_02uP-gqJ7vOwS1mCLpGiMak6jQIbqVJI/edit?usp=sharing"
        },
        {
          "title": "Payment Collection",
          "url": "https://docs.google.com/spreadsheets/d/1U_ok58d_CM-tCNU-ElCesJb04FMQn6PWD25efIY_jy8/edit?usp=sharing"
        },
        {
          "title": "Design Department Project Assignment",
          "url": "https://docs.google.com/spreadsheets/d/1ypCAkqEtP5KbBiyFxIc3dT_v_LXATowIa09a87m6uTE/edit?usp=sharing"
        },
        {
          "title": "Project Delegation for Jayesh ",
          "url": "https://docs.google.com/spreadsheets/d/1qLQIrTsubMVJm2QvpKW-toGGchS65LBOV3tPi_hF3Ss/edit?usp=sharing"
        },
        {
          "title": "Inquiry Quotation",
          "url": "https://docs.google.com/spreadsheets/d/1QkKg41XiVAW4ehGPooDqkV413Hej_PnwjmnHVlWrZW0/edit?gid=1784518143#gid=1784518143"
        },

      ];
    }

    if (normalizedRole == "MARKETING") {
      return [
        {
          "title": "EA Task Delegation",
          "url": "https://docs.google.com/spreadsheets/d/1123-Yw9w-y_02uP-gqJ7vOwS1mCLpGiMak6jQIbqVJI/edit?usp=sharing"
        },
        {
          "title": "Inquiry Quotation",
          "url": "https://docs.google.com/spreadsheets/d/1Z1WC7xJRMF84Eh3-X28mp2yL1duESMweFE7oRmpt1mI/edit?usp=sharing"
        },
        {
          "title": "Payment Collection",
          "url": "https://docs.google.com/spreadsheets/d/1U_ok58d_CM-tCNU-ElCesJb04FMQn6PWD25efIY_jy8/edit?usp=sharing"
        },
      ];
    }

    if (normalizedRole == "PRODUCTION") {
      return [
        {
          "title": "Production Sheet",
          "url": "https://docs.google.com/spreadsheets/d/ZZZZZZZZ"
        },
      ];
    }
    if (normalizedRole == "PROJECT") {
      return [
        {
          "title": "Project Delegation for Jayesh",
          "url": "https://docs.google.com/spreadsheets/d/1qLQIrTsubMVJm2QvpKW-toGGchS65LBOV3tPi_hF3Ss/edit?usp=sharing"
        },
      ];
    }
    if (normalizedRole == "DESIGN") {
      return [
        {
          "title": "Design Department Project Assignment",
          "url": "https://docs.google.com/spreadsheets/d/1ypCAkqEtP5KbBiyFxIc3dT_v_LXATowIa09a87m6uTE/edit?usp=sharing"
        },
      ];
    }
    return [];
}
