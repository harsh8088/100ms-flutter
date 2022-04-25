package com.qa.pages.MeetingRoomPage.MenuDropDown;

import com.qa.pages.MeetingRoomPage.MeetingRoom;
import io.appium.java_client.pagefactory.AndroidFindBy;
import org.openqa.selenium.WebElement;
import org.testng.Assert;

public class StartHls extends MeetingRoom {

    //@iOSXCUITFindBy(accessibility = "Start HLS")
    @AndroidFindBy(accessibility = "Start HLS")
    public WebElement startHLSBtn;

    public void click_startHLSBtn() throws InterruptedException {
        Assert.assertTrue(startHLSBtn.isDisplayed());
        startHLSBtn.click();
        Thread.sleep(3000);
    }
}
