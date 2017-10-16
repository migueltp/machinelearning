from tkinter import Tk, Canvas, Frame, Button
from datetime import datetime
import random


class Container():

    scenario = Tk()
    scenario.resizable(width=False, height=False)

    occupied_positions = []
    cell_size = 12
    agents_list = []

    stopSimulation = 0

    def __init__(self, title='Hello'):
        self.title = title
        self.DrawToolBar()
        self.scenario.title(string=title)

    def grid(self, width, height):
        self.width = width
        self.height = height
        self.occupied_positions = [[0 for x in range(self.width)] for y in range(self.height)]
        self.canvas = Canvas(self.scenario, width=self.width * self.cell_size,
                             height=self.height * self.cell_size)

        for i in range(start=0, stop=(self.width + 1) * self.cell_size, step = self.cell_size):
            self.canvas.create_line(i, 0, i, self.height * self.cell_size)
        for i in range(start=0, stop=(self.height + 1) * self.cell_size, step=self.cell_size):
            self.canvas.create_line(0, i, self.width * self.cell_size, i)
        self.canvas.pack(side='LEFT', anchor='N')

    def DrawToolBar(self):
        self.toolbar = Frame(self.scenario, bg="lightgray")
        self.stopButton = Button(self.toolbar, text='STOP', command=self.StopSimulation())
        self.stopButton.pack(side='LEFT', padx=2, pady=2)
        self.toolbar.grid(row=0, column=0)
        self.toolbar.pack(side='TOP', fill='X')

    def StopSimuation(self):
        self.stopSimulation = 1

    def stasrt(self):
        self.set_agents_position()
        self.animate()
        self.scenario.mainloop()

    def add_agents(self, agent_list):
        self_